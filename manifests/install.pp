# == Class: nextcloud::install
#
class miapache2::install {
  $paquetes = ['apache2','libapache2-mod-php7.4',
    'php7.4-gd', 'php7.4-mysql', 'php7.4-curl', 'php7.4-mbstring', 'php7.4-intl',
    'php7.4-gmp', 'php7.4-bcmath', 'php-imagick', 'php7.4-xml', 'php7.4-zip']


  $paquetesdebian = ['lsb-release', 'apt-transport-https', 'ca-certificates']

case $facts['os']['name'] {
  'Ubuntu': {

        package { 'software-properties-common':
          ensure => installed,
        }

        exec { 'update':
          command => '/usr/bin/apt update',
        }
        exec { 'addrepository':
          command => '/usr/bin/add-apt-repository ppa:ondrej/php',
          before  => Exec['update'],
        }

        $paquetes.each | String $pkgt | {
          package { $pkgt:
              ensure  => installed,
              name    => $pkgt,
              require =>[Exec['echo'],
              Service['restartapache'],
              Exec['update'],
              ],
          }
        }
}

  'Debian': {
    exec { 'update':
      command => '/usr/bin/apt -y update',
    }

    $paquetesdebian.each | String $pkg | {
      package { $pkg:
          ensure  => installed,
          name    => $pkg,
          require => Exec['update'],
      }
    }
    exec { 'wget':
      command => '/usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg',
    }

    exec { 'echo':
      command => '/usr/bin/echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list',
      require => Exec['wget'],
      before  => Exec['update'],

    }
    $paquetes.each | String $pkgt | {
      package { $pkgt:
          ensure  => installed,
          name    => $pkgt,
          require =>[Exec['echo'],
          Exec['update'],
          ],
      }
    }

}

  default: {

    exec { 'update':
      command => '/usr/bin/apt update',
    }

    $paquetesdebian.each | String $pkg | {
      package { $pkg:
          ensure  => installed,
          name    => $pkg,
          require => Exec['update'],
      }
    }
    exec { 'wget':
      command => '/usr/bin/wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg',
    }

    exec { 'echo':
      command => '/usr/bin/echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list',
      require => Exec['wget'],
      before  => Exec['update'],

    }
    $paquetes.each | String $pkgt | {
      package { $pkgt:
          ensure  => installed,
          name    => $pkgt,
          require =>[Exec['echo'],
          Exec['update'],
          ],
      }
    }
  }
}

  archive{ 'export':
      ensure          => present,
      path            => '/var/www/nextcloud-22.0.0.tar.bz2',
      #extract_command => 'tar -xjvf',
      source          => 'https://download.nextcloud.com/server/releases/nextcloud-22.0.0.tar.bz2',
      extract         => true,
      extract_path    => '/var/www/',
      before          => [File['delete'],
      File['permisos'],
      ],
  }

  file { 'delete':
  ensure => absent,
  path   => '/var/www/nextcloud-22.0.0.tar.bz2'
  }

  file { 'permisos':
  ensure  => present,
  path    => '/var/www/nextcloud',
  owner   => 'www-data',
  group   => 'www-data',
  recurse => true,
  }


  #exec { 'preparenextcloud':
  #command => '/usr/bin/sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "mysql" --database-name "nextcloud" --database-user "nextcloudroot" --database-pass "Cambiame123." --admin-user "admin" --admin-pass "Cambiame123."',
  #}

}
