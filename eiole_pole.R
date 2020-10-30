dat <- read.delim("C:/Users/a71386/Desktop/GeoHum/andres/geohumcourse/failid/eiole_pole_murdekorpus.csv", sep = ";", header = T, fileEncoding = "UTF-8")
head(dat)
names(dat)
table(dat$Alt)
library(dplyr)

unique(dat$Murrak)
dat[dat$Murrak == "Vai",]$Murre <- "Alutaguse"

murre <- vector()
murrak <- vector()
eiole <- vector()
pole <- vector()

for(i in unique(dat$Murrak)){
    print(i)
    tmp <- dat[dat$Murrak == i,]
    tmpmurre <- unique(tmp$Murre)
    tmpmurrak <- i
    tmptbl <- prop.table(table(dat[dat$Murrak == i,]$Alt))
    tmpeiole <- tmptbl["ei_ole"]
    tmppole <- tmptbl["pole"]
    murre <- append(murre, tmpmurre)
    murrak <- append(murrak, tmpmurrak)
    eiole <- append(eiole, tmpeiole)
    pole <- append(pole, tmppole)
    print(paste(length(murre),
                length(murrak),
                length(eiole),
                length(pole), " : "))
}

df <- data.frame(Murre = murre, Murrak = murrak, eiole = eiole, pole = pole)
df[is.na(df)] <- 0
head(df)
df
df[df$Murre == "Alutaguse",]$Murre <- "Kirde"

df

write.table(df, "C:/Users/a71386/Desktop/GeoHum/andres/geohumcourse/failid/eiole_pole_mk_props.csv", quote = F, sep = ";", row.names = F, fileEncoding = "UTF-8")
