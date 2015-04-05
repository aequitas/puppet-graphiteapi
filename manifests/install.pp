# == Class graphiteapi::install
#
class graphiteapi::install {
  include graphiteapi::params

  case $::operatingsystem {
    'RedHat', 'CentOS': { 
      # EPEL is needed for the packages.
      Package {
        require => Class['epel'],
      }

      # Install some Graphite API dependencies.
      package { ['cairo-devel', 'libffi-devel', 'libyaml-devel', 'libtool']: } ->
    }
    /^(Debian|Ubuntu)$/:{ 
      package { ['libcairo2-dev', 'libffi-dev', 'libyaml-dev', 'libtool']: } ->
    }
  }

  # @TODO: Decouple this a bit if possible.
  if (!defined(Class['python'])) {
    class { 'python':
      dev        => true,
      pip        => true,
      virtualenv => true,
    }
  }

  # Install graphite-api in a virtualenv.
  python::virtualenv { $graphiteapi::virtualenv_path:
    ensure  => present,
    version => 'system',
  }
  python::pip { 'graphite-api':
    virtualenv => $graphiteapi::virtualenv_path,
  } ->
  python::pip { 'gunicorn':
    virtualenv => $graphiteapi::virtualenv_path,
  }

  if $create_search_index == true {
    file { $graphiteapi_search_index:
      ensure => present,
      owner => $graphiteapi_user,
      group => $graphiteapi_group,
    }
  }
}
