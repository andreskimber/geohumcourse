# pakettide laadimine ####

paketid <- c("tidyverse", 
             "sf", 
             # "wesanderson", 
             "magrittr", 
             # "raster",
             # "plotly",
             # "leaflet", "knitr", "tmap",
             "tidyr",
             # "rio",
             # "rasterVis",
             # "lidR",
             # "rgdal",
             # "rgeos", # one side buffer jaoks
             # "lwgeom", # joonte splittimise jaoks
             # "spatialEco",  # gaussian smooth jaoks
             "rvest", "rebus", "stringr" # web scraping jaoks
)

lapply(paketid, library, character.only = TRUE)


# maakonnad ####

maakonnad_raw = st_read("./andmed/maakond_shp/maakond_20201001.shp")


# joed
joed_raw = st_read("C:/phd/thesis/analysis_phd/data/maaamet/topo_yldandmed/E_203_vooluveekogu_j.shp")

joed = joed_raw %>% 
    dplyr::filter(
        nimetus %in% c("Pärnu jõgi", "Narva jõgi", "Võhandu jõgi", "Keila jõgi", "Pirita jõgi", "Luguse jõgi", "Nuutri jõgi", 
                       "Põltsamaa jõgi", "Emajõgi", "Väike Emajõgi", "Pedja jõgi", "Kasari jõgi", "Piusa jõgi", "Navesti jõgi",
                       "Nasva jõgi"
                       ),
        tyyp_t == "Jõgi",
        telje_st00 == "Põhitelg"
        # laius_t == "Telg"
    ) %>% 
    dplyr::select(
        nimetus
    ) %>% 
    dplyr::group_by(nimetus) %>% 
    dplyr::summarise()

st_write(joed, "./andmed/joed.gpkg", append = F)

# kirikud maakonniti ####

kirikud = st_read("./andmed/kirikud.gpkg")

kirikud_maakonniti = kirikud %>% 
    count(MK_NIMI) %>% 
    st_drop_geometry() %>% 
    dplyr::rename(
        kirikuid = n, 
        maakond = MK_NIMI
    )

write.csv(kirikud_maakonniti, "./andmed/kirikud_maakonniti.csv", row.names = F)

# rastrid ####

orto_2020 = raster("./andmed/474659_OF_RGB_GeoTIFF_2020_03_23/474659.tif")

tartu_mask = st_read("./andmed/tartu_mask.gpkg")


orto_2020_crop = orto_2020 %>% 
    raster::crop(extent(tartu_mask))

raster::writeRaster(orto_2020_crop, "./andmed/orto_2020.tif", bandorder ="BIL")

# MKA ####

mka_pt_raw = st_read("./andmed/malestised_kpo_shp/malestised_kpo_shp/malestised_kpo_pt.shp")
mka_ala_raw = st_read("./andmed/malestised_kpo_shp/malestised_kpo_shp/malestised_kpo_ala.shp")
mka_pt = mka_pt_raw %>% 
    dplyr::select(
        NIMI, AJALUGU, ARHEOLOOGI, ARHITEKTUU, KUNST, REGISTRINU
    )

mka_ala = mka_ala_raw %>% 
    dplyr::select(
        NIMI, AJALUGU, ARHEOLOOGI, ARHITEKTUU, KUNST, REGISTRINU
    ) %>% 
    st_centroid()

mka = rbind(mka_ala, mka_pt)

st_write(mka, "./andmed/malestised.gpkg")


# muuseumid ####

muuseumid_raw = readr::read_delim("./andmed/KU054_20201109-092831.csv", delim = ",",
                                  skip = 2, locale = readr::locale(encoding = "UTF-8"))

muuseumid = muuseumid_raw %>% 
    filter(
        !Maakond == "..Tallinn"
    ) %>% 
    select(
        -Aasta
    )

readr::write_delim(muuseumid, "./andmed/muuseumid.csv", delim = ",")


# KNR kraapimise funktsioon ####

knr_scrape_session = function(
    kohanimi
){
    # Otsin välja veebilehe vormi
    url <- "https://www.eki.ee/dict/knr/"
    # Kõigepealt võtan tühja vormi ja sealt selgub, et tuleb ainult Q väärtus sisestada otsimiseksC
    form.unfilled <- html_session(url) %>% html_node("form") %>% html_form()
    # täidan vormi vajaliku väärtusega
    form.filled <- form.unfilled %>%
        set_values(Q = kohanimi)
    
    # submit the form and save as a new session
    # Võiks kuidagi ümber teha, et iga kord ei alustaks uut sessiooni. Saaks kiiremaks
    session <- submit_form(html_session(url), form.filled) 
    # tekst_tervik = session %>% html_nodes(xpath = "/html/body/div[1]/div[4]") # %>% html_text() # %>% str_trim() %>% unlist() # ".tervikart"
    # võtan kihelkonna nime kõigepealt. vajalike, et sorteerida välja hiljem teistes kihelkondades olevad samanimelised asulad
    kn_khk = session %>%
        html_nodes(".khk") %>% html_text()
    # võtan nimekujud ja aastad
    # . valib class'i ja # valib id. Need saab veebilehe html koodist. Võib kasutada ka xpathi, mille saab kopeerida html koodist parema klikiga
    # saab kätte määratud järjekorras kõik nimekujud ja aastad 
    # kn_nmk_a = session %>% 
    #   html_nodes(".khk, .k, .a_n_ca, .a, .nmk, .txj") %>% html_text() %>%  # txj võib ära jätta, kuna tähistab liiki (küla, mõis jne). peaks panema sulgudesse
    #   paste(collapse = " ") %>% # panen üheks vectoriks kokku ja lisan iga klassi vahele tühiku
    #   str_replace_all(" [1]", ", 1") # lisan numbrite ette koma, et oleks arusaadav, mis aasta mis nimega kokku läheb ja oleks samamoodi nagu KNRis
    # võtan ka kohainfo
    # peamiselt meie enda jaoks, et saaks samanimeliste külade puhul eristada meid huvitavas vallas oleva.
    kn_kohainfo = session %>% 
        html_nodes(".koht") %>% 
        html_text()
    # kn_kohainfo  
    # panen kokku tabeli kõigi tulemustega
    # kn_ety1 = session %>% 
    #   html_nodes(".ety1")
    # kn_ety2 = session %>% 
    #   html_nodes(".ety2")
    kn_tervik = session %>% 
        html_nodes(".tervikart") %>% 
        html_text()
    knr_tulemus = tibble(
        kohanimi = kohanimi,
        kihelkond = kn_khk,
        # ajaloolised_nimetused = kn_nmk_a,
        # kui vastuseid on rohkem kui üks (näiteks küla Nasva) siis tuleb tibble error. seetõttu võtan praegu ainult esimese vastuse ehk [1].
        # peab kindlasti parandama!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        kohainfo = kn_kohainfo[1],
        # kohainfo_2 = kn_kohainfo[2],
        # kohainfo_3 = kn_kohainfo[3],
        tervikartikkel = kn_tervik[1]
    )
    return(knr_tulemus)
}

# kraapimise funkstiooni rakendamine nimekirjale ja sellest tabeli kokku panemine
knr_scrape = function(
    kohtade_list
){
    knr_tabel = lapply(kohtade_list, knr_scrape_session) %>% # kasutn knr_scrape funktsiooni nimekirja peal. saan tulemuseks list of lists
        lapply(., as.vector) %>% # teen listi kõiki listid vectoriteks 
        do.call(rbind, .) %>% # seon need vektorid ridadena kokku
        as.data.frame()
    # juhend https://stackoverflow.com/questions/54558022/converting-a-list-of-lists-into-a-data-frame-in-r/54558305
    return(knr_tabel)
}

# kohanimeraamatust kraabitud andmete puhastamine
knr_clean = function(
    knr_data#,
    # maakond # selle põhjal filtreeritakse teiste maakondade samanimelised kohad välja
){
    knr_cleaned = knr_data %>% # $ajaloolised_nimetused 
        mutate(
            nimekujud = str_match(.$tervikartikkel, "1\\d{3} (.*?)\\.")[,1] %>% as.character(), 
            # seletus: vali tekst, mis jääb number ühega algava neljakohalise arvu (st ühele järgneb kolm numbrit) ja punkti vahele.
            # Punktiga algab etümoloogia tekst.
            # regex katsetused
            # vallas\\,?
            # 1\\d{1,4} valid number ühega algavad ja järgneb vähemalt 1 ja kuni 4 numbrit 
            # \\. näitab, et punkt peab olema viimane asi kuhumaani võtab.  
            # paste(.$kohainfo, "(.*)\\.", sep = "") # katsetus, et sortida välja vastavalt sellele, mis kohainfo tulbas olemas. 
            # Jätab aga selle kohainfo ka lahtrisse
            # õpetus https://stackoverflow.com/questions/39086400/extracting-a-string-between-other-two-strings-in-r
            # teen etümoloogia tulba. tärnist kuni lõpuni. võiks ka vähem võtta. 
            etymoloogia = str_match(.$tervikartikkel, "●.*(.*?).*")[,1] %>% as.character() %>% str_replace("● ", ""),
        ) %>% 
        # filtreerin teiste maakondade kohad
        # dplyr::filter(
        #     grepl(maakond, kohainfo)
        # ) %>% 
        dplyr::select(
            !tervikartikkel
        )
    return(knr_cleaned)
}
# tegeleda olukordadega, kus tuleb kaks või rohkem tulemust ühele kohale, millel samas maakonnas ja kihelkonnas sama nimi. Siin praegu Voka näide

# toila_kylad = st_read("H:/data/yldplaneeringud/arh_tundlikud_alad/arheoloogia_tundlikud_alad.gpkg" , 
#                       layer = "ajaloolised_kylad_toila",  crs = 3301)
# toila_knr = knr_scrape(toila_kylad$nimi)
# 
# toila_knr_puhas = knr_clean(
#     knr_data = toila_knr,
#     maakond = "Ida-Viru"
# )

# Hiiumaa külad #### 

hiiu_kylad_raw = read_csv2("./andmed/hiiu_kylad.csv")

hiiu_kylad = hiiu_kylad_raw %>% 
    select(
        Kohanimi, X, Y
    ) %>% 
    mutate(
        Kohanimi = str_replace_all(Kohanimi, " küla", "") %>% 
            # kustutan külanimedel sidekriipsu ees oleva teksti. see on eksitav minu arust
            str_replace_all("^.+-", "")
    ) #%>% 
    # filter(
    #     !Kohanimi == "Nasva"
    # ) %>% 
    # slice(
    #     1:20
    # )

hiiu_knr = knr_scrape(hiiu_kylad$Kohanimi)
hiiu_knr_puhas = knr_clean(hiiu_knr) #, maakond = "Hiiu"
 
hiiu_knr_puhas2 = hiiu_knr_puhas %>% 
    filter(
        kihelkond %in% c("Phl", "Emm", "Rei", "Käi")
    )

hiiu_esmamainimine = hiiu_knr_puhas2 %>% 
    mutate(
        # valin ainult aastaarvu ja teen eraldi tulbaks 
        esmamainimine = str_match(.$nimekujud, "1\\d{3}")[,1] %>% as.double(),
        # eraldi tulpa asustusüksus. valin kõik mis enne on enne white space'i
        asustusyksus = str_match(.$kohainfo, "\\w+")[,1] %>% as.character()
    ) %>%
    relocate(c(asustusyksus, esmamainimine, nimekujud), .after = kohanimi) %>% 
    filter(
        asustusyksus == "küla"
    )

hiiu_join = hiiu_kylad %>% 
    left_join(., hiiu_esmamainimine, by = c(Kohanimi = "kohanimi"))

# write_csv2(hiiu_join, "./andmed/hiiu_kylad.csv")

# Tartumaa asustus ####

tartu_kylad_raw = read_delim("./andmed/tartu_kylad_kohanimeregister.csv", delim = ";", locale=locale(decimal_mark = "."))

tartu_kylad = tartu_kylad_raw %>% 
    select(
        Kohanimi, X, Y
    ) %>% 
    mutate(
        Kohanimi = str_replace_all(Kohanimi, " küla", "") %>% 
            # kustutan külanimedel sidekriipsu ees oleva teksti. see on eksitav minu arust
            str_replace_all("^.+-", "")
    )

tartu_knr = knr_scrape(tartu_kylad$Kohanimi)

write_csv2(tartu_knr, "./andmed/tartu_knr_scrape_raw.csv")

tartu_knr_puhas = knr_clean(tartu_knr) #, maakond = "tartu"

tartu_knr_puhas2 = tartu_knr_puhas %>% 
    filter(
        kihelkond %in% c("Plt", "Ksi", "Äks", "MMg", "Kod", "TMr", "Nõo", "Puh", "Ran", "Rõn", "Ote", "Kam", "Võn")
    )

tartu_esmamainimine = tartu_knr_puhas2 %>% 
    mutate(
        # valin ainult aastaarvu ja teen eraldi tulbaks 
        esmamainimine = str_match(.$nimekujud, "1\\d{3}")[,1] %>% as.double(),
        # eraldi tulpa asustusüksus. valin kõik mis enne on enne white space'i
        asustusyksus = str_match(.$kohainfo, "\\w+")[,1] %>% as.character()
    ) %>%
    relocate(c(asustusyksus, esmamainimine, nimekujud), .after = kohanimi) %>% 
    filter(
        asustusyksus %in% c("küla", "alevik", "paik"),
        !is.na(esmamainimine)#,
        # esmamainimine < 1800
    )

tartu_join = tartu_esmamainimine %>% 
    left_join(., tartu_kylad, by = c(kohanimi = "Kohanimi"))

write_csv2(tartu_join, "./andmed/tartumaa_asustus.csv")
