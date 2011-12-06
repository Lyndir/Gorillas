#!/usr/bin/ruby

#
#  WARNING: DO NOT MODIFY THIS FILE.
#
#  Crashlytics
#  Crashlytics Version: 0009.07.00
#
#  Created by Jeff Seibert on 7/16/11.
#  Copyright Crashlytics, Inc. 2011. All rights reserved.
#

require 'pathname'

path = Pathname.new(__FILE__).parent
`#{path}/../../../run`