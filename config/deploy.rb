require 'mina/bundler'
require 'mina/rails'
require 'mina/git'

set :domain, '60.247.110.148'
set :deploy_to, '/web/2013/eshare'
set :current_path, 'current'
set :repository, 'git://github.com/mindpin/beikong-eshare.git'
set :branch, 'develop'
set :user, 'root'

set :shared_paths, [
  # 以下文件在各个部署环境存在区别，部署时不会被版本库中的文件覆盖

  # 调查问卷模板
  'config/survey_templates',
  # 数据库连接信息
  'config/database.yml',
  # 数据库 migration 记录
  'db/schema.rb',
  # 日志文件夹
  'log', 
  # 进程记录文件夹
  'tmp/pids',
  # rvm 版本标识
  '.ruby-version',
  # 静态文件目录配置信息
  'deploy/sh/property.yaml',
  # ????
  'public/YKAuth.txt',
  # 用于远程 lisences 校验的信息 
  'public/project_key',
  # 新浪微博应用信息（八中版没有用到）
  'config/oauth_key.yaml',
  # 一些第三方库的配置信息
  'config/initializers/r.rb',
  # R 的另外一些配置，包括选课模式和皮肤信息
  'config/deploy_env.rb'
]

task :environment do
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config/initializers"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]
  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue! %[touch "#{deploy_to}/shared/config/oauth_key.yaml"]
  queue! %[touch "#{deploy_to}/shared/config/initializers/r.rb"]

  queue! %[mkdir -p "#{deploy_to}/shared/config/survey_templates"]

  queue! %[mkdir -p "#{deploy_to}/shared/db"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/db"]
  queue! %[touch "#{deploy_to}/shared/db/schema.rb"]

  queue! %[mkdir -p "#{deploy_to}/shared/deploy/sh"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/deploy/sh"]
  queue! %[touch "#{deploy_to}/shared/deploy/sh/property.yaml"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/project_key"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/project_key"]
  queue! %[touch "#{deploy_to}/shared/public/YKAuth.txt"]

  queue! %[touch "#{deploy_to}/shared/.ruby-version"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/oauth_key.yaml'."]
  queue  %[echo "-----> Be sure to edit 'shared/db/schema.rb'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/initializers/r.rb'."]
  queue  %[echo "-----> Be sure to edit 'shared/.ruby-version'."]
  queue  %[echo "-----> Be sure to edit 'shared/deploy/sh/property.yaml'."]
  queue  %[echo "-----> Be sure to edit 'shared/public/YKAuth.txt'."]
  queue  %[echo "-----> Be sure to edit 'shared/config/deploy_env.rb'."]
end

desc "init_verify_key"
task :init_verify_key => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue! "bundle"
    queue! "ruby script/init_verify_key.rb"
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue! "bundle"
    # invoke :'bundle:install'
    # invoke :'rails:db_migrate'
    queue! "bundle exec rake db:create RAILS_ENV=production"
    queue! "bundle exec rake db:migrate RAILS_ENV=production"
    invoke :'rails:assets_precompile'

    to :launch do
      queue %[
        source /etc/profile
        ./deploy/sh/redis_server.sh restart
        ./deploy/sh/solr_server.sh stop
        ./deploy/sh/solr_server.sh start
        ./deploy/sh/sidekiq.sh restart
        ./deploy/sh/faye.sh restart
        ./deploy/sh/unicorn_eshare.sh stop
        ./deploy/sh/unicorn_eshare.sh start
      ]
    end
  end
end

desc "update code only"
task :update_code => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
  end
end

desc "restart server"
task :restart => :environment do
  queue %[
    source /etc/profile
    cd #{deploy_to}/#{current_path}
    ./deploy/sh/redis_server.sh restart
    ./deploy/sh/solr_server.sh stop
    ./deploy/sh/solr_server.sh start
    ./deploy/sh/sidekiq.sh restart
    ./deploy/sh/faye.sh restart
    ./deploy/sh/unicorn_eshare.sh stop
    ./deploy/sh/unicorn_eshare.sh start
  ]
end
# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

