
require('calabash').do 'watch compile',
  'pkill -f doodle'
  'coffee -o src/ -wb coffee/'
  'doodle index.html src/'
