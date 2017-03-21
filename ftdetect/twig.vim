if has("autocmd")
  au BufNewFile,BufRead *.twig set filetype=html.twig
  au BufNewFile,BufRead *.html.twig set filetype=html.twig
  au BufNewFile,BufRead *.xml.twig set filetype=xml.twig
endif
