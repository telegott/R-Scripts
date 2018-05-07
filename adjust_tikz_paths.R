#!/usr/bin/env Rscript

if (!require("pacman")) install.packages("pacman")
pacman::p_load(glue, crayon, tidyverse)

all_tikz_files <- list.files(pattern = '\\.tikz$', recursive = TRUE, full.names = TRUE)

tikz_files_with_figures <- all_tikz_files %>% 
  keep(
    ~ read_lines(.) %>% 
    str_detect(fixed('ras1}}')) %>%
    any
  ) 

for (tikz_file in tikz_files_with_figures) {
  
  tik_file_dir <- dirname(tikz_file)
  tikz_file_pattern <- tools::file_path_sans_ext(basename(tikz_file)) %>% 
    str_c('_ras')
  tikz_file_content <- read_lines(tikz_file)
  
  lines_with_figure_links <- tikz_file_content %>% 
    map_lgl(~ str_detect(., pattern = fixed(tikz_file_pattern))) %>% which
  if (length(lines_with_figure_links) == 0) {
    cat(crayon::red(paste0(tikz_file, ' does not link to correct file! \n')))
    next
  }  
  
  for (line in lines_with_figure_links) {
    
    current_line <- tikz_file_content[line]
    
    start <- str_locate_all(current_line, fixed('{'))[[1]][1, 1]
    
    end <- str_locate_all(current_line, fixed('}'))[[1]][1, 2]
    
    current_path <- str_sub(current_line, start + 1, end - 1)
    
    current_basename <- basename(current_path)
    
    new_path <- glue::glue('{tik_file_dir}/{current_basename}') %>% str_sub(3)
    
    if(!file.exists(glue::glue('{new_path}.png'))) {
      cat(crayon::yellow(paste0('File ', new_path, '.png does not exist. \n')))
    }
    
    if (current_path == new_path) {
      cat(glue::glue(crayon::green('File {tikz_file} already contained a correct path.\n')))
    } else {
      
      tikz_file_content[line] <- current_line %>% str_replace(fixed(current_path), new_path)
      
      message <- paste0(
        'Path ',
        crayon::red(current_path),
        ' in file ',
        crayon::cyan(tikz_file),
        ' changed to ',
        crayon::green(new_path),
        ' \n'
      )
      write_lines(tikz_file_content, tikz_file)
      cat(message)
      
    }
    
  }
  
}




