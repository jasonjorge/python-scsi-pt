#!/usr/bin/env python

# Copyright 2014 Larry Fenske

# This file is part of the Python SCSI Toolkit.

# The Python SCSI Toolkit is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# The Python SCSI Toolkit is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

from ScsiPT import *
from CDB import *
from AppLogging import *


if __name__ == "__main__":
    logger.info("version:".format(ScsiPT.sg.scsi_pt_version()))
    pt = ScsiPT(b"/dev/sdb")
    cdb_tur = CDB([0, 0, 0, 0, 0, 0])

    retval = pt.sendcdb(cdb_tur)
    logger.info("retval for TUR: {}".format(retval))
    logger.info("TUR sense     : {}".format(pt.dumpbuf(cdb_tur.sense)))
    del cdb_tur

    alloc = 0x60
    cdb_inq = CDB([0x12, 0, 0, 0, alloc, 0])
    cdb_inq.set_data_in(alloc)
    retval = pt.sendcdb(cdb_inq)
    logger.info("retval for inq: {}".format(retval))
    logger.info("sense         : {}".format(pt.dumpbuf(cdb_inq.sense)))
    logger.info('inq data      : {}'.format(pt.dumpbuf(cdb_inq.buf)))
    del cdb_inq

    # vdb pages
    alloc = 0x24
    cdb_inqpages = CDB([0x12, 0x01, 0x00, 0x00, alloc, 0x00])
    cdb_inqpages.set_data_in(alloc)
    retval = pt.sendcdb(cdb_inqpages)
    logger.info("retval for inqpages: {}".format(retval))
    logger.info("inqpages sense     : {}".format(pt.dumpbuf(cdb_inqpages.sense)))
    inqpages = pt.dumpbuf(cdb_inqpages.buf)
    logger.info('inqpages data      : {}'.format(inqpages))
    logger.debug('Number of valid pages: {}'.format(inqpages[6:8]))
    # pages = [x for x in inqpages]
    x = 10
    validpages = []
    for i in range(int(inqpages[6:8])-1):  # subtract 1 for page 00
        validpages.append(inqpages[x:x+2])
        x += 2
    logger.debug(validpages)
    # exit()

    # identify via SCSI passthrough
    alloc = 0x200
    cdb_ptident = CDB([0xa1, 0x08, 0x0E, 0x00, 0x01, 0x00, 0x00, 0x00, 0xA0, 0xEC, 0x00, 0x00])  # identify via ScsiPt16
    cdb_ptident.set_data_in(alloc)
    retval = pt.sendcdb(cdb_ptident)
    logger.info("retval for pt_inq: {}".format(retval))
    logger.info("pt_inq sense     : {}".format(pt.dumpbuf(cdb_ptident.sense)))
    # ptinq = pt.dumpbuf(cdb_ptinq.buf)
    # logger.info('inqpages data             : {}'.format(ptinq))
    ptinqbs = pt.dumpbuf(cdb_ptident.buf, True)
    logger.info('Identify via SCSI-Passthrough data byteswapped : {}'.format(ptinqbs))

    del cdb_inq
    del cdb_ptident
    del pt
