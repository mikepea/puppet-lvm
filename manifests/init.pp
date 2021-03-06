define lvm::volume($vg, $pv, $fstype, $size = undef, $ensure) {
  case $ensure {
    #
    # Clean up the whole chain.
    #
    cleaned: {
      physical_volume { $pv: ensure => present }
      volume_group { $vg: ensure => present, physical_volumes => $pv, before => Physical_volume[$pv] }
      logical_volume { $name: ensure => present, volume_group => $vg, size => $size, before => Volume_group[$vg] }
    }
    #
    # Just clean up the logical volume
    #
    absent: {
      logical_volume { $name: ensure => absent, volume_group => $vg, size => $size }
    }
    #
    # Create the whole chain.
    #
    present: {
      physical_volume { $pv: ensure => present }
      volume_group { $vg: ensure => present, physical_volumes => $pv, require => Physical_volume[$pv] }
      logical_volume { $name: ensure => present, volume_group => $vg, size => $size, require => Volume_group[$vg] }
      filesystem { "/dev/${vg}/${name}": ensure => $fstype, require => Logical_volume[$name] }
    }
    default: {
     fail ( 'puppet-lvm::volume: ensure parameter can only be set to cleaned, absent or present' )
    }
  }
}
