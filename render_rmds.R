for(i in list.files(pattern = ".Rmd")){
    rmarkdown::render(i)
}
# koo index.Rmd igaks juhuks uuesti
rmarkdown::render("index.Rmd")