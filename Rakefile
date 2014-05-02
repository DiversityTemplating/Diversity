#...


# To develop diversity-ruby while using bundler here, use:
#
# bundle config local.diversity ~/diversity-ruby
# bundle config disable_local_branch_check true
task :local_diversity, [:path] do
  sh 'bundle config local.diversity #{path}'
  sh 'bundle config disable_local_branch_check true'
end


task :install do
  sh 'bundle install --path vendor'
end

task :start do
  sh 'bundle exec thin -R config.ru start'
end
