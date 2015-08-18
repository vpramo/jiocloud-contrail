require 'spec_helper'

describe 'contrail::repo::apt' do
  let (:facts) { {
    :lsbdistid       => 'ubuntu',
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
  } }

  context 'with defaults' do
    it do
      should contain_apt__source('contrailv2').with({
        'location'  => 'http://jiocloud.rustedhalo.com/contrailv2/',
        'release'   => 'trusty',
        'repos'     => 'main',
        'include_src'=> false,
      })
    end
  end
end
