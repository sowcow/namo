guard :shell do
  watch('input.md') { `rake` }
  watch('Rakefile') { `rake` }
end
 
guard :livereload do
  watch 'output.html'
end
