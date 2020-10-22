library(xml2)
library(dplyr)
library(rvest)


pb <- txtProgressBar(0, 6, style = 3)
df_tamm <- data.frame(stringsAsFactors = F)
for(n in 1:6){
    address <- paste("http://www.ra.ee/apps/andmed/index.php/request/aaut?perenimi=Tamm&q=1&page=", n, sep = "")
    dat <- read_html(address)
    links <- html_nodes(dat, "a")
    hrefs <-html_attr(links, "href")
    matriklid <- grep("matrikkel", hrefs, value = TRUE)
    
    for(i in 1:length(matriklid)){
        tmp <-matriklid[i]
        tmp2 <- paste("http://www.ra.ee", tmp, sep = "")
        tmpdat <- read_html(tmp2)
        tbls <- html_table(tmpdat)
        tbl1 <- tbls[[1]]
        cols <- tbl1$X1
        vals <- tbl1$X2
        if(length(vals) == 15){
            # jäta rahvus välja
            vals <- vals[c(1:5, 7:15)]
            cols <- cols[c(1:5, 7:15)]
        }
        df_tamm <- rbind(df_tamm, vals)
        names(df_tamm) <- cols
        Sys.sleep(runif(1, min = 1, max = 2))
    }
    setTxtProgressBar(pb, n)
}

pb <- txtProgressBar(0, 5, style = 3)
df_saar <- data.frame(stringsAsFactors = F)
for(n in 1:5){
    address <- paste("http://www.ra.ee/apps/andmed/index.php/request/aaut?perenimi=Saar&q=1&page=", n, sep = "")
    dat <- read_html(address)
    links <- html_nodes(dat, "a")
    hrefs <-html_attr(links, "href")
    matriklid <- grep("matrikkel", hrefs, value = TRUE)
    
    for(i in 1:length(matriklid)){
        tmp <-matriklid[i]
        tmp2 <- paste("http://www.ra.ee", tmp, sep = "")
        tmpdat <- read_html(tmp2)
        tbls <- html_table(tmpdat)
        tbl1 <- tbls[[1]]
        cols <- tbl1$X1
        vals <- tbl1$X2
        if(length(vals) == 15){
            # jäta rahvus välja
            vals <- vals[c(1:5, 7:15)]
            cols <- cols[c(1:5, 7:15)]
        }
        df_saar <- rbind(df_saar, vals)
        names(df_saar) <- cols
        
        Sys.sleep(runif(1, min = 1, max = 2))
    }
    setTxtProgressBar(pb, n)
}


write.table(x = df_tamm, file = "./failid/tamm_tabel.csv", quote = F, sep = "\t", row.names = F, fileEncoding = "UTF-8")
write.table(x = df_saar, file = "./failid/saar_tabel.csv", quote = F, sep = "\t", row.names = F, fileEncoding = "UTF-8")

df_tamm$pk <- "Tamm"
df_saar$pk <- "Saar"

koond <- rbind(df_tamm, df_saar)
sk <- koond$Sünnikoht
length(sk) # 196

koond$Sünnikoht_std <- NA

yksnimi <- grep("^[^ ]+$", sk, value = TRUE) # nt Põltsamaa
sk2 <- sk[!sk %in% yksnimi]
length(sk2) # 118
unique(yksnimi) # Tln, Pbg, Jä, Ha, Trtm

lyh_vald <- grep("^[^ ]+ [^ ]+ v$", sk2, value = TRUE) # nt Trtm Sootaga v
sk3 <- sk2[!sk2 %in% lyh_vald]
length(sk3) # 35
unique(gsub("^([^ ]+) .*$", "\\1", lyh_vald)) # Võ, Vil, Pä, Trtm, Vir, Ha, Sa, Jä, Pe, Lä, Hiiumaa

lyh_v_muu <- grep("^[^ ]+ [^ ]+ v .*$", sk3, value = TRUE)
sk4 <- sk3[!sk3 %in% lyh_v_muu]
length(sk4) # 19
unique(gsub("^([^ ]+) [^ ]+ v .*$", "\\1", lyh_v_muu)) # Võ, Vir, Jä, Sa, Trtm, Pä, Vil
unique(gsub("^[^ ]+ ([^ ]+) v .*$", "\\1", lyh_v_muu))
unique(gsub("^[^ ]+ [^ ]+ v (.*)$", "\\1", lyh_v_muu))

lyh_muu <- grep("^[^ ]+ [^ ]+$", sk4, value = TRUE)
sk5 <- sk4[!sk4 %in% lyh_muu]
length(sk5) # 9
unique(gsub("^([^ ]+) .*$", "\\1", lyh_muu)) # Ha, Lä, Vn, Pä, Vir

unique(gsub("^([^ ]+) .*$", "\\1", sk5)) # Lä, Lvm, Krm, Vn, Pbg
# kub, khk, mk

for(i in 1:nrow(koond)){
    tm <- koond[i,]
    tm_sk <- tm$Sünnikoht
    tm_sk
    if(tm_sk %in% yksnimi){
        # Tln, Pbg, Jä, Ha, Trtm
        tm_pikk <- ifelse(tm_sk %in% c("Tln", "Pbg", "Jä", "Ha", "Trtm"), switch(tm_sk, "Tln" = "Tallinn", "Pbg" = "Peterburi", "Jä" = "Järvamaa", "Ha" = "Harjumaa", "Trtm" = "Tartumaa"), tm_sk)
        koond[i,]$Sünnikoht_std <- tm_pikk
        
    }else if(tm_sk %in% lyh_vald){
        # Võ, Vil, Pä, Trtm, Vir, Ha, Sa, Jä, Pe, Lä, Hiiumaa
        tm_lyh <- gsub("^([^ ]+) .*$", "\\1", tm_sk)
        tm_pikk <- switch(tm_lyh, "Võ" = "Võrumaa", "Vil" = "Viljandimaa", "Pä" = "Pärnumaa", "Trtm" = "Tartumaa", "Vir" = "Virumaa", "Ha" = "Harjumaa", "Sa" = "Saaremaa", "Jä" = "Järvamaa", "Pe" = "Petserimaa", "Lä" = "Läänemaa", "Hiiumaa" = "Hiiumaa")
 
        koond[i,]$Sünnikoht_std <- paste(tm_pikk, gsub("^[^ ]+ ([^ ]+ )v$", ", \\1vald", tm_sk), sep = "")
        
    }else if(tm_sk %in% lyh_v_muu){
        # Võ, Vir, Jä, Sa, Trtm, Pä, Vil
        tm_lyh <- gsub("^([^ ]+) .*$", "\\1", tm_sk)
        tm_pikk <- switch(tm_lyh, "Võ" = "Võrumaa", "Vir" = "Virumaa", "Pä" = "Pärnumaa", "Trtm" = "Tartumaa", "Sa" = "Saaremaa", "Jä" = "Järvamaa", "Vil" = "Viljandimaa")
        
        koond[i,]$Sünnikoht_std <- paste(tm_pikk, gsub("^[^ ]+ ([^ ]+ )v (.*)$", ", \\1vald, \\2", tm_sk), sep = "")
        
    }else if(tm_sk %in% lyh_muu){
        # Ha, Lä, Vn, Pä, Vir
        tm_lyh <- gsub("^([^ ]+) .*$", "\\1", tm_sk)
        tm_pikk <- switch(tm_lyh, "Ha" = "Harjumaa", "Lä" = "Läänemaa", "Vn" = "Venemaa", "Pä" = "Pärnumaa", "Vir" = "Virumaa")
        koond[i,]$Sünnikoht_std <- paste(tm_pikk, gsub("^[^ ]+ (.*)$", ", \\1", tm_sk), sep = "")
    }else{
        tm_sk <- gsub("^(.*) khk$", "\\1 kihelkond", tm_sk)
        tm_sk <- gsub(" kub ", " kubermang, ", tm_sk)
        tm_sk <- gsub("^(.*) kub$", "\\1 kubermang", tm_sk)
        tm_sk <- gsub(" mk ", " maakond, ", tm_sk)
        tm_lyh <- gsub("^([^ ]+) .*$", "\\1", tm_sk)
        tm_pikk <- switch(tm_lyh, "Jä" = "Järvamaa", "Lvm" = "Liivimaa", "Krm" = "Kuramaa", "Vn" = "Venemaa", "Pbg" = "Peterburi")
        
    }
}

names(koond)
koond <- koond[,c(1:7,16,8:15)]

write.table(koond,"./failid/tamm_saar_koond.csv", quote = F, sep = "\t", row.names = F, fileEncoding = "UTF-8")


### Vallakohtuprotokollid

vk <- fail <- read.csv("C:/Users/a71386/Desktop/ekkd_vallakohtud/vallakohtud_16_dec_2019-tahemarkidega_lihts.csv", 
                       quote = "", header = TRUE, sep = "|", encoding = "UTF-8")

head(vk)
names(vk)
vk <- vk[,c(1,3:7,11:14)]
head(vk)
unique(vk$maakond)

write.table(vk, "./failid/praks_19okt/vallakohtud_RA.csv", quote = F, sep = "\t", row.names = F, fileEncoding = "UTF-8")
