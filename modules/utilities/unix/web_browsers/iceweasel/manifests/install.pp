class iceweasel::install{
  if $facts['os']['family'] == 'Debian' and $facts['os']['release']['major'] == '7' {
    package { 'iceweasel':
      ensure => 'installed',
    }
  } else {
    package { 'firefox-esr':
      ensure => 'installed',
    }
  }
}
