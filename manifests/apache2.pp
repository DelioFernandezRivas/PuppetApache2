# == Class: nextcloudmio::apache2
#
class miapache2::apache2 {

  case $facts['os']['family'] {
    'Debian': {
      $rute1 = '/etc/apache2/sites-available/'
      $rute2 = '/etc/apache2/conf-available/'
    }

    'Rhel': {
      $rute1 = '/etc/httpd/conf.d/'
      $rute2 = '/etc/httpd/conf-available/'
    }
    default: {
      $rute1 = '/etc/apache2/sites-available/'
      $rute2 = '/etc/apache2/conf-available/'
    }
  }

  file { 'conf_apache2':
      ensure => present,
      path   => "${rute1}/nextcloudssl.conf",
      source => 'puppet:///modules/nextcloudmio/nextcloudssl.conf',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
      before =>  Exec['available_site'],
  }

  exec { 'available_site':
    command => '/usr/sbin/a2ensite nextcloudssl.conf',
  }

  service { 'restartapache':
    ensure     => running,
    name       => 'apache2',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

  exec { 'createsslcertificates':
    command    => '/usr/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -subj "/C=ES/ST=Spain/L=Madrid/O=Acme S.A./CN=www.nextcloudpuppet.com" -out /etc/ssl/certs/apache-selfsigned.crt',
  }

  exec { 'habilitarssl':
    command => '/usr/sbin/a2enmod ssl',
    before  => [Exec['createsslcertificates'],
    ]
  }

  file { 'conf_ssl':
      ensure  => present,
      path    => "${rute2}/ssl-params.conf",
      source  => 'puppet:///modules/nextcloudmio/ssl-params.conf',
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      require => [Exec['habilitarssl'],
      Exec['available_site'],
      ]
      before  => Service['restartapache'],
  }
}
