# Class: datadog_agent::suse
#
# This class contains the DataDog agent installation mechanism for SUSE distributions
#

class datadog_agent::suse(
  Integer $agent_major_version = $datadog_agent::params::default_agent_major_version,
  String $agent_version = $datadog_agent::params::agent_version,
  String $release = $datadog_agent::params::apt_default_release,
  Optional[String] $agent_repo_uri = undef,
) inherits datadog_agent::params {


  case $agent_major_version {
    5 : { fail('Agent v5 package not available in SUSE') }
    6 : {
      $repos = '6'
      $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY.public'
    }
    7 : {
      $repos = '7'
      $gpgkey = 'https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public'
    }
    default: { fail('invalid agent_major_version') }
  }

  if ($agent_repo_uri != undef) {
    $baseurl = $agent_repo_uri
  } else {
    $baseurl = "https://yum.datadoghq.com/suse/${release}/${agent_major_version}/${::architecture}"
  }

  package { 'datadog-agent-base':
    ensure => absent,
    before => Package[$datadog_agent::params::package_name],
  }

  zypprepo { 'datadog':
    baseurl      => $baseurl,
    enabled      => 1,
    autorefresh  => 1,
    name         => 'datadog',
    gpgcheck     => 0, # FIXME: Update if we sign the repository
    gpgkey       => $gpgkey,
    keeppackages => 1,
  }

  package { $datadog_agent::params::package_name:
    ensure  => $agent_version,
  }

}
