node default {

  include jenkins
  include mongodb
  include apache2

  package {
    [ 'wget', 'vim', 'mc', 'htop', 'git', 'maven', 'tree' ] : ensure => latest
  }

  file { "apache2-config":
    path => "/etc/apache2/sites-enabled/000-default",
    source => "puppet:///apache2-config/sites-enabled/default",
    require => Package["apache2"],
  }

  apache2::module {
    [ "proxy", "proxy_http" ] : ,
  }

  if $operatingsystem == 'Fedora' {
    package { 'ack' : ensure => installed }
  }

  if $operatingsystem == 'Ubuntu' {
    package { 'ack-grep' : ensure => installed }
  }

  File {
    owner => "jenkins",
    group => "jenkins",
    mode => 770,
  }

  file {"jenkins_home":
    path => "/home/jenkins",
    ensure => directory,
  }

  file {".m2":
    path => "/home/jenkins/.m2",
    ensure => directory,
    require => File["jenkins_home"],
  }

  file { ".m2/settings.xml":
    path => "/home/jenkins/.m2/settings.xml",
    source => "puppet:///maven-config/settings.xml",
    ensure => present,
    require => [ Package["maven"], File[".m2"] ],
  }

  file { "jenkins-service-conf":
    path => "/etc/default/jenkins",
    source => "puppet:///jenkins-config/jenkins-service-conf",
    ensure => present,
    notify => Service["jenkins"],
  }

  file { "git-jenkins-plugin":
    path => "/var/lib/jenkins/hudson.plugins.git.GitSCM.xml",
    source => "puppet:///jenkins-config/hudson.plugins.git.GitSCM.xml",
    ensure => present,
  }

  file { "ant-jenkins-plugin":
    path => "/var/lib/jenkins/hudson.tasks.Ant.xml",
    source => "puppet:///jenkins-config/hudson.tasks.Ant.xml",
    ensure => present,
  }

  file { "maven-jenkins-plugin":
    path => "/var/lib/jenkins/hudson.tasks.Maven.xml",
    source => "puppet:///jenkins-config/hudson.tasks.Maven.xml",
    ensure => present,
  }

  jenkins::plugin {
        "git" : ;
        "git-client" : ;
        "maven-plugin" : ;
        "jira" : ;
        "gitlab-hook" : ;
        "ghprb" : ;
        "monitoring" : ;
        "greenballs" : ;
        "github-oauth" : ;
  }

}
