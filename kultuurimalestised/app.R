# See rakendus kuvab veebikaardi kultuurimälestistest.
#
# Rakenduse sisendfailideks on
# maakond_20201001.shp ja kultuurimalestised.shp.
#
# Rakendus kasutab pakette shiny, sf ja tidyverse (sh ggplot2).
#
# Maarja-Liisa Pilvik
# 7.12.2020

# 1. Laadime paketid ja loeme sisse andmed ----
library(shiny) # vajalik rakenduse töötamiseks
library(sf) # vajalik ruumiandmete sisselugemiseks ja analüüsiks
library(tidyverse) # sisaldab paketti ggplot2 (visualiseerimiseks) ja dplyr (andmetöötluseks)

# Loeme andmestikud sisse (las need olla rakenduse kaustas).
maakonnad  = st_read("maakond_20201001.shp")
malestised = st_read("kultuurimalestised.shp")

# Teeme kultuurimälestiste laiast tabelist (mälestiste liigid eraldi tulpades, st KUNST: Y-N, ARHITEKTUUR: Y-N jne) samanimelise pika tabeli, kus oleks ainult üks tulp mälestiste liikidega (LIIK: KUNST, ARHITEKTUUR, ...).
malestised <- gather(malestised, # andmestik, mida muuta
                     key = LIIK, # vanade tulpade nimed uude tulpa LIIK
                     value = yesno, # vanade tulpade väärtused uude tulpa yesno
                     AJALUGU:KUNST) %>% # vanad tulbad ise
    filter(yesno == "Y") %>% # jäta alles ainult read, kus yesno väärtus on "Y"
    select(-yesno) # seejärel viska yesno tulp andmestikust välja

# Muudame mälestiste liikide väärtused (nt ARHEOLOOGI) ilusamaks (nt Arheoloogia).
malestised$LIIK <- recode(malestised$LIIK, # muudame tulpa "LIIK"
                          AJALUGU = "Ajalugu", 
                          ARHEOLOOGI = "Arheoloogia", 
                          ARHITEKTUU = "Arhitektuur", 
                          KUNST = "Kunst")

# 2. Defineerime kasutajaliidese (user interface ehk ui) ----
ui <- fluidPage( # vaade, mis kohandub kasutaja brauseriakna suurusega
    
    # Rakenduse pealkiri
    titlePanel("Eesti kultuurimälestised"),
    
    # Valime vaates sellise elementide paigutuse,
    # mis koosneb külgrgibamenüüst ja väljundist
    sidebarLayout(
        # külgribamenüüs on
        sidebarPanel( 
            checkboxGroupInput( # linnukestega menüü, kus:
                inputId = "liik", # suvaline nimi, millega menüüd tähistada
                label = "Vali mälestiste liik", # kuvatav juhendtekst
                choices = unique(malestised$LIIK)), # liigid ise
            selectInput( # valikmenüü,kus: 
                inputId = "maakond", # suvaline nimi, millega menüüd tähistada
                label = "Vali maakond", # kuvatav juhendtekst
                choices = c(unique(maakonnad$MNIMI), "Kõik maakonnad"), # maakonnad
                selected = "Kõik maakonnad", # vaikimisi valitud kõik
                multiple = FALSE)), # mitut korraga valida ei saa
        
        # väljundiks on
        mainPanel( 
            plotOutput( # joonis, kus:
                outputId = "kaart")) # suvaline nimi, millega joonist tähistada
    )
)

# 3. Defineerime serveri loogika ehk selle, mida rakendus teeb ----
server <- function(input, output){
    
    # Kasutajaliidese väljundi (output) koha peale 'kaart'
    output$kaart <- renderPlot({ # tehakse joonis,
        
        # mille sisendandmed sõltuvad kasutaja valikutest
        # mälestiste kihil
        andmed <- filter(malestised, # filtreeri mälestistest need read, kus
                         LIIK %in% input$liik) # liik vastab kasutaja valikutele
        
        # ja suumimine sõltub kasutaja valikutest 
        # maakondade kihil
        suum <- if(input$maakond == "Kõik maakonnad") # kui valitud on kõik
            st_bbox(maakonnad) # siis võta terve maakondade kihi piirid
        else # vastasel juhul
            st_bbox(maakonnad %>% # võta piirid ainult
                        filter(MNIMI == input$maakond)) # valitud maakonnast
        
        
        # Kui sisendandmed ja suumi tase valitud, tee ggplotiga joonis, kus
        ggplot() +
            # on alati maakondade kiht (ei sõltu kasutaja valikutest)
            geom_sf(data = maakonnad) + 
            # ning mälestiste kiht (sõltub kasutaja valikutest)
            geom_sf(data = andmed, # valikutest tulenevad andmed
                    aes(shape = LIIK, color = LIIK), # kuju ja värv liigi järgi
                    alpha = 0.3, # punktide väljapaistvus 30%
                    size = 3) + # punktide suurus 3
            # suumi sisse vastavalt kasutaja valikutele maakondade sisendis
            coord_sf(xlim = c(suum["xmin"], suum["xmax"]),
                     ylim = c(suum["ymin"], suum["ymax"])) +
            # lisa kaardile pealkiri vastava maakonna nimega
            labs(title = input$maakond) +
            # kuva kaarti mustvalge teemaga
            theme_bw() +
            # aseta legend kaardi alla
            theme(legend.position = "bottom")
    })
    
}

shinyApp(ui = ui, server = server)