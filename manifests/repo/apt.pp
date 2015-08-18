#
# Class: contrail::repo::apt
#
class contrail::repo::apt (
  $location    = 'http://jiocloud.rustedhalo.com/contrailv2/',
  $release     = 'trusty',
  $repos       = 'main',
  $include_src = false,
){

  ::apt::source { 'contrailv2':
    location    => $location,
    release     => $release,
    repos       => $repos,
    include_src => $include_src,
  }
}
