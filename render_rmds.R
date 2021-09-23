setwd(choose.dir()) # geohumcourse
for(i in list.files(pattern = "^[^_].*Rmd")){
    rmarkdown::render(i)
}
# koo index.Rmd igaks juhuks uuesti
rmarkdown::render("index.Rmd")
