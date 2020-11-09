

# maakonnad 

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

# kirikud maakonniti

kirikud = st_read("./andmed/kirikud.gpkg")

kirikud_maakonniti = kirikud %>% 
    count(MK_NIMI) %>% 
    st_drop_geometry() %>% 
    dplyr::rename(
        kirikuid = n, 
        maakond = MK_NIMI
    )

write.csv(kirikud_maakonniti, "./andmed/kirikud_maakonniti.csv", row.names = F)

# rastrid

orto_2020 = raster("./andmed/474659_OF_RGB_GeoTIFF_2020_03_23/474659.tif")

tartu_mask = st_read("./andmed/tartu_mask.gpkg")


orto_2020_crop = orto_2020 %>% 
    raster::crop(extent(tartu_mask))

raster::writeRaster(orto_2020_crop, "./andmed/orto_2020.tif", bandorder ="BIL")

# MKA 

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


# muuseumid 

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
