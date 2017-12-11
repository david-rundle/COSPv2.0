module mod_cosp_io
  use cosp_kinds, only: wp
  use mod_cosp,   only: cosp_outputs
  use netcdf
  USE MOD_COSP_CONFIG, ONLY: &!R_UNDEF, PARASOL_NREFL, LIDAR_NCAT, SR_BINS, N_HYDRO,     &
      ! RTTOV_MAX_CHANNELS, numMISRHgtBins, DBZE_BINS,LIDAR_NTEMP,calipso_histBsct,     &
      ! use_vgrid, Nlvgrid, vgrid_zu, vgrid_zl, vgrid_z, numMODISTauBins,               &
      ! numMODISPresBins, numMODISReffIceBins, numMODISReffLiqBins, numISCCPTauBins,    &
      ! numISCCPPresBins, numMISRTauBins,  modis_histTau,,           &
       ! modis_histTauEdges, modis_histTauCenters,
       Nlvgrid, LIDAR_NCAT, SR_BINS, PARASOL_NREFL, DBZE_BINS, numMODISReffIceBins, numMODISReffLiqBins,&
       ntau, tau_binBounds, tau_binCenters, tau_binEdges, &
       npres, pres_binBounds, pres_binCenters, pres_binEdges, &
       nhgt, hgt_binBounds, hgt_binCenters, hgt_binEdges
  implicit none

contains

  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ! SUBROUTINE write_cosp2_output
  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  subroutine write_cosp2_output(Npoints, Ncolumns, Nlevels, lon, lat, cospOUT,outFileName)
    integer,intent(in) :: Npoints, Ncolumns, Nlevels
    real(wp),dimension(nPoints),intent(in) :: lon,lat
    type(cosp_outputs),intent(in) :: cospOUT
    character(len=256),intent(in) :: outFileName

    integer :: fileID,status
    integer,dimension(20)  :: dimID
    integer,dimension(100) :: varID

    
    ! ---------------------------------------------------------------------------------------
    ! Create output file.
    ! ---------------------------------------------------------------------------------------
    status = nf90_create(path=trim(outFileName),cmode = nf90_clobber,ncid=fileID)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))

    ! ---------------------------------------------------------------------------------------
    ! Define dimensions.
    ! ---------------------------------------------------------------------------------------
    status = nf90_def_dim(fileID,"loc",Npoints,dimID(1))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"cosp_scol",Ncolumns,dimID(2))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"lev",Nlevels,dimID(3))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"levStat",Nlvgrid,dimID(4))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"tau7",ntau,dimID(5))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"bnds",2,dimID(6))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"pres7",npres,dimID(7))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"hgt16",nhgt,dimID(8))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"SR_BINS",SR_BINS,dimID(12))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"PARASOL_NREFL",PARASOL_NREFL,dimID(13))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"DBZE_BINS",DBZE_BINS,dimID(14))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"RELIQ_MODIS",numMODISReffLiqBins,dimID(15))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_def_dim(fileID,"REICE_MODIS",numMODISReffIceBins,dimID(16))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))

    ! ---------------------------------------------------------------------------------------
    ! Define varaibles
    ! ---------------------------------------------------------------------------------------
    ! Longitude
    status = nf90_def_var(fileID,"longitude",  nf90_float, (/dimID(1)/),varID(1))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(1),"long_name","longitude")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(1),"units",        "degrees_east")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Latitude
    status = nf90_def_var(fileID,"latitude",   nf90_float, (/dimID(1)/),varID(2))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(2),"long_name","latitude")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(2),"units",        "degrees_north")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Joint-histogram axis
    ! Tau
    status = nf90_def_var(fileID,"tau7",        nf90_float, (/dimID(5)/),varID(3))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(3),"long_name","cloud_optical_depth_bin_centers")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(3),"units",        "1")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Tau edges
    status = nf90_def_var(fileID,"tau7_bnds",   nf90_float, (/dimID(6),dimID(5)/),varID(4))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(4),"long_name","cloud_optical_depth_bin_edges")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(4),"units",        "1")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Pressure
    status = nf90_def_var(fileID,"pres7",      nf90_float, (/dimID(7)/),varID(5))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(5),"long_name","air_pressure_bin_centers")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(5),"units",        "Pa")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Pressure Edges
    status = nf90_def_var(fileID,"pres7_bnds", nf90_float, (/dimID(6),dimID(7)/),varID(6))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(6),"long_name","air_pressure_bin_edges")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(6),"units",        "Pa")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Height
    status = nf90_def_var(fileID,"hgt16",       nf90_float, (/dimID(8)/),varID(7))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(7),"long_name","altitude_bin_centers")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(7),"units",        "m")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Height Edges
    status = nf90_def_var(fileID,"hgt16_bnds",  nf90_float, (/dimID(6),dimID(8)/),varID(8))
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(8),"long_name","altitude_bin_edges")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_att(fileID,varID(8),"units",        "m")
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))

    ! CALIPSO simulator output
    if (associated(cospOUT%calipso_betaperp_tot)) then
       status = nf90_def_var(fileID,"atb532_perp",nf90_float, (/dimID(1),dimID(2),dimID(3)/),varID(9))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(9),"long_name","Calipso Attenuated Total Perpendicular Backscatter (532nm)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(9),"units",        "m-1 sr-1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))      
    endif
    if (associated(cospOUT%calipso_beta_tot)) then
       status = nf90_def_var(fileID,"atb532",nf90_float, (/dimID(1),dimID(2),dimID(3)/),varID(10))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(10),"long_name","Calipso Attenuated Total Backscatter (532nm)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(10),"units",        "m-1 sr-1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))      
    endif
    if (associated(cospOUT%calipso_tau_tot)) then
       status = nf90_def_var(fileID,"calipso_tau",nf90_float, (/dimID(1),dimID(2),dimID(3)/),varID(11))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(11),"long_name","Calipso optical-thickness @ 0.67microns")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(11),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_lidarcldphase)) then
       ! Ice
       status = nf90_def_var(fileID,"clcalipsoice",nf90_float, (/dimID(1),dimID(4)/),varID(58))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(58),"long_name","Calipso cloud-fraction (ice)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(58),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
       ! Liquid
       status = nf90_def_var(fileID,"clcalipsoliq",nf90_float, (/dimID(1),dimID(4)/),varID(59))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(59),"long_name","Calipso cloud-fraction (liquid)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(59),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! Undefined
       status = nf90_def_var(fileID,"clcalipsoun",nf90_float, (/dimID(1),dimID(4)/),varID(60))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(60),"long_name","Calipso cloud-fraction (undetermined)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(60),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_cldlayerphase)) then
       ! Ice
       status = nf90_def_var(fileID,"cllcalipsoice",nf90_float, (/dimID(1)/),varID(61))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(61),"long_name","Calipso low-level cloud fraction (ice)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(61),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clmcalipsoice",nf90_float, (/dimID(1)/),varID(62))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(62),"long_name","Calipso mid-level cloud fraction (ice)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(62),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clhcalipsoice",nf90_float, (/dimID(1)/),varID(63))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(63),"long_name","Calipso high-level cloud fraction (ice)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(63),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"cltcalipsoice",nf90_float, (/dimID(1)/),varID(64))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(64),"long_name","Calipso total cloud fraction (ice)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(64),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! Liquid
       status = nf90_def_var(fileID,"cllcalipsoliq",nf90_float, (/dimID(1)/),varID(65))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(65),"long_name","Calipso low-level cloud fraction (liquid)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(65),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clmcalipsoliq",nf90_float, (/dimID(1)/),varID(66))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(66),"long_name","Calipso mid-level cloud fraction (liquid)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(66),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clhcalipsoliq",nf90_float, (/dimID(1)/),varID(67))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(67),"long_name","Calipso high-level cloud fraction (liquid)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(67),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"cltcalipsoliq",nf90_float, (/dimID(1)/),varID(68))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(68),"long_name","Calipso total cloud fraction (liquid)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(68),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! Undetermined
       status = nf90_def_var(fileID,"cllcalipsoun",nf90_float, (/dimID(1)/),varID(69))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(69),"long_name","Calipso low-level cloud fraction (undetermined)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(69),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clmcalipsoun",nf90_float, (/dimID(1)/),varID(70))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(70),"long_name","Calipso mid-level cloud fraction (undetermined)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(70),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clhcalipsoun",nf90_float, (/dimID(1)/),varID(71))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(71),"long_name","Calipso high-level cloud fraction (undetermined)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(71),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"cltcalipsoun",nf90_float, (/dimID(1)/),varID(72))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(72),"long_name","Calipso total cloud fraction (undetermined)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(72),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_lidarcldtmp)) then
       status = nf90_def_var(fileID,"clcalipsotmp",nf90_float, (/dimID(1),dimID(4)/),varID(77))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(77),"long_name","Calipso cloud-fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(77),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clcalipsotmpice",nf90_float, (/dimID(1),dimID(4)/),varID(78))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(78),"long_name","Calipso cloud-fraction (ice)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(78),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
       status = nf90_def_var(fileID,"clcalipsotmpliq",nf90_float, (/dimID(1),dimID(4)/),varID(79))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(79),"long_name","Calipso cloud-fraction (liquid)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(79),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_def_var(fileID,"clcalipsotmpun",nf90_float, (/dimID(1),dimID(4)/),varID(80))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(80),"long_name","Calipso cloud-fraction (undetermined)")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(80),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%calipso_cfad_sr)) then
       status = nf90_def_var(fileID,"cfadLidarsr532",nf90_float, (/dimID(1),dimID(12),dimID(4)/),varID(15))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(15),"long_name","Calipso Scattering Ratio CFAD")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(15),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_lidarcld)) then
       status = nf90_def_var(fileID,"calipso_lidarcld",nf90_float, (/dimID(1),dimID(4)/),varID(16))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(16),"long_name","Calipso cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(16),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_cldlayer)) then
       ! Low-level
       status = nf90_def_var(fileID,"cllcalipso",nf90_float, (/dimID(1)/),varID(73))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(73),"long_name","Calipso low-level cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(73),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
       ! Mid-level
       status = nf90_def_var(fileID,"clmcalipso",nf90_float, (/dimID(1)/),varID(74))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(74),"long_name","Calipso mid-level cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(74),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! High-level
       status = nf90_def_var(fileID,"clhcalipso",nf90_float, (/dimID(1)/),varID(75))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(75),"long_name","Calipso high-level cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(75),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! Total
       status = nf90_def_var(fileID,"cltcalipso",nf90_float, (/dimID(1)/),varID(76))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(76),"long_name","Calipso total cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(76),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_beta_mol)) then
       status = nf90_def_var(fileID,"lidarBetaMol532",nf90_float, (/dimID(1),dimID(3)/),varID(18))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(18),"long_name","Calipso molecular backscatter coefficient")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(18),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%calipso_srbval)) then
       status = nf90_def_var(fileID,"calipso_srbval",nf90_float, (/dimID(6),dimID(12)/),varID(19))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(19),"long_name","Calipso SR BINS")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(19),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    
    ! PARASOL simulator output
    if (associated(cospOUT%parasolPix_refl)) then
       status = nf90_def_var(fileID,"parasolPix_refl",nf90_float, (/dimID(1),dimID(2),dimID(13)/),varID(20))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(20),"long_name","PARASOL subcolumn bidirectional reflectances")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(20),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%parasolGrid_refl)) then
       status = nf90_def_var(fileID,"parasolGrid_refl",nf90_float, (/dimID(1),dimID(13)/),varID(21))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(21),"long_name","PARASOL  bidirectional reflectances")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(21),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif

    ! Cloudsat simulator output
    if (associated(cospOUT%cloudsat_Ze_tot)) then
       status = nf90_def_var(fileID,"dbze94",nf90_float, (/dimID(1),dimID(2),dimID(3)/),varID(22))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(22),"long_name","Cloudsat radar reflectivity")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(22),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))       
    endif
    if (associated(cospOUT%cloudsat_cfad_ze)) then
       status = nf90_def_var(fileID,"cfadDbze94",nf90_float, (/dimID(1),dimID(14),dimID(4)/),varID(23))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(23),"long_name","Cloudsat radar reflectivity CFAD")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(23),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    ! ISCCP simulator outputs
    if (associated(cospOUT%isccp_totalcldarea)) then
       status = nf90_def_var(fileID,"cltisccp",nf90_float, (/dimID(1)/),varID(24))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(24),"long_name","ISCCP cloud cover")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(24),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_meantb)) then
       status = nf90_def_var(fileID,"meantbisccp",nf90_float, (/dimID(1)/),varID(25))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(25),"long_name","ISCCP all-sky 10.5 micron brightness temperature")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(25),"units",        "K")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_meantbclr)) then
       status = nf90_def_var(fileID,"meantbclrisccp",nf90_float, (/dimID(1)/),varID(26))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(26),"long_name","ISCCP clear-sky 10.5 micron brightness temperature")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(26),"units",        "K")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_meanptop)) then
       status = nf90_def_var(fileID,"pctisccp",nf90_float, (/dimID(1)/),varID(27))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(27),"long_name","ISCCP cloud-top pressure")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(27),"units",        "mb")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_meantaucld)) then
       status = nf90_def_var(fileID,"tauisccp",nf90_float, (/dimID(1)/),varID(28))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(28),"long_name","ISCCP optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(28),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_meanalbedocld)) then
       status = nf90_def_var(fileID,"albisccp",nf90_float, (/dimID(1)/),varID(29))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(29),"long_name","ISCCP cloud albedo")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(29),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_boxtau)) then
       status = nf90_def_var(fileID,"boxtauisccp",nf90_float, (/dimID(1),dimID(2)/),varID(30))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(30),"long_name","ISCCP subcolumn optical-depth")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(30),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%isccp_boxptop)) then
       status = nf90_def_var(fileID,"boxptopisccp",nf90_float, (/dimID(1),dimID(2)/),varID(31))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(31),"long_name","ISCCP subcolumn cloud-top pressure")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(31),"units",        "mb")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%isccp_fq)) then	    
       status = nf90_def_var(fileID,"clisccp",nf90_float, (/dimID(1),dimID(5),dimID(7)/),varID(32))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(32),"long_name","ISCCP CFAD")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(32),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    ! MISR simulator output
    if (associated(cospOUT%misr_fq)) then
       status = nf90_def_var(fileID,"clMISR",nf90_float, (/dimID(1),dimID(5),dimID(8)/),varID(33))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(33),"long_name","MISR CFAD")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(33),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%misr_meanztop)) then
       status = nf90_def_var(fileID,"misr_meanztop",nf90_float, (/dimID(1)/),varID(34))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(34),"long_name","MISR cloud-top height")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(34),"units",        "m")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%misr_cldarea)) then	    
       status = nf90_def_var(fileID,"misr_cldarea",nf90_float, (/dimID(1)/),varID(35))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(35),"long_name","MISR cloud cover")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(35),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    ! MODIS simulator output
    if (associated(cospOUT%modis_Cloud_Fraction_Total_Mean)) then
       status = nf90_def_var(fileID,"cltmodis",nf90_float, (/dimID(1)/),varID(36))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(36),"long_name","MODIS total cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(36),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Water_Mean)) then
       status = nf90_def_var(fileID,"clwmodis",nf90_float, (/dimID(1)/),varID(37))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(37),"long_name","MODIS liquid cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(37),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Ice_Mean)) then
       status = nf90_def_var(fileID,"climodis",nf90_float, (/dimID(1)/),varID(38))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(38),"long_name","MODIS ice cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(38),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_High_Mean)) then
       status = nf90_def_var(fileID,"clhmodis",nf90_float, (/dimID(1)/),varID(39))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(39),"long_name","MODIS high cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(39),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Mid_Mean)) then
       status = nf90_def_var(fileID,"clmmodis",nf90_float, (/dimID(1)/),varID(40))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(40),"long_name","MODIS mid cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(40),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Low_Mean)) then
       status = nf90_def_var(fileID,"cllmodis",nf90_float, (/dimID(1)/),varID(41))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(41),"long_name","MODIS low cloud fraction")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(41),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Total_Mean)) then
       status = nf90_def_var(fileID,"tautmodis",nf90_float, (/dimID(1)/),varID(42))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(42),"long_name","MODIS total optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(42),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Water_Mean)) then
       status = nf90_def_var(fileID,"tauwmodis",nf90_float, (/dimID(1)/),varID(43))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(43),"long_name","MODIS liquid optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(43),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Ice_Mean)) then
       status = nf90_def_var(fileID,"tauimodis",nf90_float, (/dimID(1)/),varID(44))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(44),"long_name","MODIS ice optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(44),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif

    if (associated(cospOUT%modis_Optical_Thickness_Total_logMean)) then
       status = nf90_def_var(fileID,"tautlogmodis",nf90_float, (/dimID(1)/),varID(45))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(45),"long_name","MODIS total log10 optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(45),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Water_logMean)) then
       status = nf90_def_var(fileID,"tauwlogmodis",nf90_float, (/dimID(1)/),varID(46))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(46),"long_name","MODIS liquid log10 optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(46),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Ice_logMean)) then
       status = nf90_def_var(fileID,"tauilogmodis",nf90_float, (/dimID(1)/),varID(47))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(47),"long_name","MODIS ice log10 optical-thickness")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(47),"units",        "1")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Particle_Size_Water_Mean)) then
       status = nf90_def_var(fileID,"reffclwmodis",nf90_float, (/dimID(1)/),varID(48))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(48),"long_name","MODIS liquid particle size")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(48),"units",        "m")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Particle_Size_Ice_Mean)) then
       status = nf90_def_var(fileID,"reffclimodis",nf90_float, (/dimID(1)/),varID(49))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(49),"long_name","MODIS ice particle size")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(49),"units",        "m")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%modis_Cloud_Top_Pressure_Total_Mean)) then
       status = nf90_def_var(fileID,"pctmodis",nf90_float, (/dimID(1)/),varID(50))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(50),"long_name","MODIS cloud-top pressure")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(50),"units",        "mb")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%modis_Liquid_Water_Path_Mean)) then
       status = nf90_def_var(fileID,"lwpmodis",nf90_float, (/dimID(1)/),varID(51))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(51),"long_name","MODIS liquid water path")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(51),"units",        "kg m-2")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%modis_Ice_Water_Path_Mean)) then
       status = nf90_def_var(fileID,"iwpmodis",nf90_float, (/dimID(1)/),varID(52))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(52),"long_name","MODIS ice water path")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(52),"units",        "kg m-2")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%modis_Optical_Thickness_vs_Cloud_Top_Pressure)) then
       status = nf90_def_var(fileID,"clmodis",nf90_float, (/dimID(1),dimID(5),dimID(7)/),varID(53))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(53),"long_name","MODIS CFAD")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(53),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%modis_Optical_Thickness_vs_ReffICE)) then
       status = nf90_def_var(fileID,"modis_Optical_Thickness_vs_ReffICE",nf90_float, (/dimID(1),dimID(5),dimID(16)/),varID(54))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(54),"long_name","MODIS Joint-PDF of optical-depth and ice particle size")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(54),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%modis_Optical_Thickness_vs_ReffLIQ)) then
       status = nf90_def_var(fileID,"modis_Optical_Thickness_vs_ReffLIQ",nf90_float, (/dimID(1),dimID(5),dimID(15)/),varID(55))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(55),"long_name","MODIS Joint-PDF of optical-depth and liquid particle size")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(55),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%lidar_only_freq_cloud)) then
       status = nf90_def_var(fileID,"clcalipso2",nf90_float, (/dimID(1),dimID(4)/),varID(56))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(56),"long_name","Calipso cloud fraction undetected by CloudSat")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(56),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    if (associated(cospOUT%radar_lidar_tcc)) then
       status = nf90_def_var(fileID,"cltlidarradar",nf90_float, (/dimID(1)/),varID(57))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(57),"long_name","Calipso and CloudSat total cloud amount")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_att(fileID,varID(57),"units",        "%")
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status)) 
    endif
    
    ! ---------------------------------------------------------------------------------------
    ! Exit define mode
    ! ---------------------------------------------------------------------------------------
    status = nf90_enddef(fileID)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))

    ! ---------------------------------------------------------------------------------------
    ! Populate outputs
    ! ---------------------------------------------------------------------------------------
    ! Geo
    status = nf90_put_var(fileID,varID(1),lon)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_var(fileID,varID(2),lat)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    ! Joint-histogram axis variables
    status = nf90_put_var(fileID,varID(3),tau_binCenters)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_var(fileID,varID(4),tau_binEdges)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_var(fileID,varID(5),pres_binCenters)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_var(fileID,varID(6),pres_binEdges)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_var(fileID,varID(7),hgt_binCenters)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    status = nf90_put_var(fileID,varID(8),hgt_binEdges)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))

    ! CALIPSO simulator output
    if (associated(cospOUT%calipso_betaperp_tot)) then
       status = nf90_put_var(fileID,varID(9),cospOUT%calipso_betaperp_tot)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_beta_tot)) then
       status = nf90_put_var(fileID,varID(10),cospOUT%calipso_beta_tot)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_tau_tot)) then
       status = nf90_put_var(fileID,varID(11),cospOUT%calipso_tau_tot)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_lidarcldphase)) then
       status = nf90_put_var(fileID,varID(58),cospOUT%calipso_lidarcldphase(:,:,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(59),cospOUT%calipso_lidarcldphase(:,:,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(60),cospOUT%calipso_lidarcldphase(:,:,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_cldlayerphase)) then
       ! Ice
       status = nf90_put_var(fileID,varID(61),cospOUT%calipso_cldlayerphase(:,1,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(62),cospOUT%calipso_cldlayerphase(:,2,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(63),cospOUT%calipso_cldlayerphase(:,3,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(64),cospOUT%calipso_cldlayerphase(:,4,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! Liquid
       status = nf90_put_var(fileID,varID(65),cospOUT%calipso_cldlayerphase(:,1,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(66),cospOUT%calipso_cldlayerphase(:,2,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(67),cospOUT%calipso_cldlayerphase(:,3,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(68),cospOUT%calipso_cldlayerphase(:,4,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       ! Undetermined
       status = nf90_put_var(fileID,varID(69),cospOUT%calipso_cldlayerphase(:,1,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(70),cospOUT%calipso_cldlayerphase(:,2,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(71),cospOUT%calipso_cldlayerphase(:,3,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(72),cospOUT%calipso_cldlayerphase(:,4,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_lidarcldtmp)) then
       status = nf90_put_var(fileID,varID(77),cospOUT%calipso_lidarcldtmp(:,:,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(78),cospOUT%calipso_lidarcldtmp(:,:,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(79),cospOUT%calipso_lidarcldtmp(:,:,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(80),cospOUT%calipso_lidarcldtmp(:,:,4))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_cfad_sr)) then
       status = nf90_put_var(fileID,varID(15),cospOUT%calipso_cfad_sr)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_lidarcld)) then
       status = nf90_put_var(fileID,varID(16),cospOUT%calipso_lidarcld)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_cldlayer)) then
       status = nf90_put_var(fileID,varID(73),cospOUT%calipso_cldlayer(:,1))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(74),cospOUT%calipso_cldlayer(:,2))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(75),cospOUT%calipso_cldlayer(:,3))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
       status = nf90_put_var(fileID,varID(76),cospOUT%calipso_cldlayer(:,4))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_beta_mol)) then
       status = nf90_put_var(fileID,varID(18),cospOUT%calipso_beta_mol)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%calipso_srbval)) then
       status = nf90_put_var(fileID,varID(19),reshape([cospOUT%calipso_srbval(1:SR_BINS),cospOUT%calipso_srbval(2:SR_BINS+1)],(/2,SR_BINS/)))
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    ! PARASOL simulator output
    if (associated(cospOUT%parasolPix_refl)) then
       status = nf90_put_var(fileID,varID(20),cospOUT%parasolPix_refl)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%parasolGrid_refl)) then
       status = nf90_put_var(fileID,varID(21),cospOUT%parasolGrid_refl)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    ! Cloudsat simulator output
    if (associated(cospOUT%cloudsat_Ze_tot)) then
       status = nf90_put_var(fileID,varID(22),cospOUT%cloudsat_Ze_tot)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%cloudsat_cfad_ze)) then
       status = nf90_put_var(fileID,varID(23),cospOUT%cloudsat_cfad_ze)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif

    if (associated(cospOUT%isccp_totalcldarea)) then
       status = nf90_put_var(fileID,varID(24),cospOUT%isccp_totalcldarea)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_meantb)) then
       status = nf90_put_var(fileID,varID(25),cospOUT%isccp_meantb)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_meantbclr)) then
       status = nf90_put_var(fileID,varID(26),cospOUT%isccp_meantbclr)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_meanptop)) then
       status = nf90_put_var(fileID,varID(27),cospOUT%isccp_meanptop)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_meantaucld)) then
       status = nf90_put_var(fileID,varID(28),cospOUT%isccp_meantaucld)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_meanalbedocld)) then
       status = nf90_put_var(fileID,varID(29),cospOUT%isccp_meanalbedocld)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_boxtau)) then
       status = nf90_put_var(fileID,varID(30),cospOUT%isccp_boxtau)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_boxptop)) then
       status = nf90_put_var(fileID,varID(31),cospOUT%isccp_boxptop)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%isccp_fq)) then	    
       status = nf90_put_var(fileID,varID(32),cospOUT%isccp_fq)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    ! MISR simulator output
    if (associated(cospOUT%misr_fq)) then
       status = nf90_put_var(fileID,varID(33),cospOUT%misr_fq)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%misr_meanztop)) then
       status = nf90_put_var(fileID,varID(34),cospOUT%misr_meanztop)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%misr_cldarea)) then	    
       status = nf90_put_var(fileID,varID(35),cospOUT%misr_cldarea)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    ! MODIS simulator output
    if (associated(cospOUT%modis_Cloud_Fraction_Total_Mean)) then
       status = nf90_put_var(fileID,varID(36),cospOUT%modis_Cloud_Fraction_Total_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Water_Mean)) then
       status = nf90_put_var(fileID,varID(37),cospOUT%modis_Cloud_Fraction_Water_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Ice_Mean)) then
       status = nf90_put_var(fileID,varID(38),cospOUT%modis_Cloud_Fraction_Ice_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_High_Mean)) then
       status = nf90_put_var(fileID,varID(39),cospOUT%modis_Cloud_Fraction_High_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Mid_Mean)) then
       status = nf90_put_var(fileID,varID(40),cospOUT%modis_Cloud_Fraction_Mid_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Cloud_Fraction_Low_Mean)) then
       status = nf90_put_var(fileID,varID(41),cospOUT%modis_Cloud_Fraction_Low_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Total_Mean)) then
       status = nf90_put_var(fileID,varID(42),cospOUT%modis_Optical_Thickness_Total_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Water_Mean)) then
       status = nf90_put_var(fileID,varID(43),cospOUT%modis_Optical_Thickness_Water_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Ice_Mean)) then 
       status = nf90_put_var(fileID,varID(44),cospOUT%modis_Optical_Thickness_Ice_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))      
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Total_LogMean)) then
       status = nf90_put_var(fileID,varID(45),cospOUT%modis_Optical_Thickness_Total_LogMean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Water_LogMean)) then
       status = nf90_put_var(fileID,varID(46),cospOUT%modis_Optical_Thickness_Water_LogMean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))
    endif
    if (associated(cospOUT%modis_Optical_Thickness_Ice_LogMean)) then 
       status = nf90_put_var(fileID,varID(47),cospOUT%modis_Optical_Thickness_Ice_LogMean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))      
    endif
    if (associated(cospOUT%modis_Cloud_Particle_Size_Water_Mean)) then
       status = nf90_put_var(fileID,varID(48),cospOUT%modis_Cloud_Particle_Size_Water_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Particle_Size_Ice_Mean)) then
       status = nf90_put_var(fileID,varID(49),cospOUT%modis_Cloud_Particle_Size_Ice_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Cloud_Top_Pressure_Total_Mean)) then
       status = nf90_put_var(fileID,varID(50),cospOUT%modis_Cloud_Top_Pressure_Total_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Liquid_Water_Path_Mean)) then
       status = nf90_put_var(fileID,varID(51),cospOUT%modis_Liquid_Water_Path_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Ice_Water_Path_Mean)) then
       status = nf90_put_var(fileID,varID(52),cospOUT%modis_Ice_Water_Path_Mean)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_vs_Cloud_Top_Pressure)) then          			   
       status = nf90_put_var(fileID,varID(53),cospOUT%modis_Optical_Thickness_vs_Cloud_Top_Pressure)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_vs_ReffICE)) then
       status = nf90_put_var(fileID,varID(54),cospOUT%modis_Optical_Thickness_vs_ReffICE)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%modis_Optical_Thickness_vs_ReffLIQ)) then
       status = nf90_put_var(fileID,varID(55),cospOUT%modis_Optical_Thickness_vs_ReffLIQ)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%lidar_only_freq_cloud)) then
       status = nf90_put_var(fileID,varID(56),cospOUT%lidar_only_freq_cloud)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif
    if (associated(cospOUT%radar_lidar_tcc)) then
       status = nf90_put_var(fileID,varID(57),cospOUT%radar_lidar_tcc)
       if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))  
    endif

    ! Close file
    status = nf90_close(fileID)
    if (status .ne. nf90_NoERR) print*,trim(nf90_strerror(status))

  end subroutine write_cosp2_output



































  
  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ! SUBROUTINE nc_read_input_file
  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  SUBROUTINE NC_READ_INPUT_FILE(fname,Npnts,Nl,Nhydro,lon,lat,p,ph,z,zh,T,qv,rh,tca,cca, &
                                mr_lsliq,mr_lsice,mr_ccliq,mr_ccice,fl_lsrain,fl_lssnow, &
                                fl_lsgrpl,fl_ccrain,fl_ccsnow,Reff,dtau_s,dtau_c,dem_s,  &
                                dem_c,skt,landmask,mr_ozone,u_wind,v_wind,sunlit,        &
                                emsfc_lw,mode,Nlon,Nlat)
     
    ! Arguments
    character(len=512),intent(in) :: fname ! File name
    integer,intent(in) :: Npnts,Nl,Nhydro
    real(wp),dimension(Npnts),intent(out) :: lon,lat
    real(wp),dimension(Npnts,Nl),target,intent(out) :: p,ph,z,zh,T,qv,rh,tca,cca, &
         mr_lsliq,mr_lsice,mr_ccliq,mr_ccice,fl_lsrain,fl_lssnow,fl_lsgrpl, &
         fl_ccrain,fl_ccsnow,dtau_s,dtau_c,dem_s,dem_c,mr_ozone
    real(wp),dimension(Npnts,Nl,Nhydro),intent(out) :: Reff
    real(wp),dimension(Npnts),intent(out) :: skt,landmask,u_wind,v_wind,sunlit
    real(wp),intent(out) :: emsfc_lw
    integer,intent(out) :: mode,Nlon,Nlat
    
    ! Local variables
    integer,parameter :: NMAX_DIM=5
    integer :: Npoints,Nlevels,i,j,k,vrank,vdimid(NMAX_DIM),ncid,vid,ndims,nvars,ngatts, &
               recdim,dimsize(NMAX_DIM),errst,Na,Nb,Nc,Nd,Ne
    integer,dimension(:),allocatable :: plon,plat
    logical :: Llat,Llon,Lpoint
    real(wp),dimension(Npnts) :: ll
    real(wp),allocatable :: x1(:),x2(:,:),x3(:,:,:),x4(:,:,:,:),x5(:,:,:,:,:) ! Temporary arrays
    character(len=128) :: vname
    character(len=256) :: dimname(NMAX_DIM) ! 256 hardcoded, instead of MAXNCNAM. This works for NetCDF 3 and 4.
    character(len=64) :: routine_name='NC_READ_INPUT_FILE'
    character(len=128) :: errmsg,straux
    
    mode = 0
    Nlon = 0
    Nlat = 0
    
    Npoints = Npnts
    Nlevels = Nl
    
    ! Open file
    errst = nf90_open(fname, nf90_nowrite, ncid)
    if (errst /= 0) then
       errmsg="Couldn't open "//trim(fname)
       call cosp_error(routine_name,errmsg)
    endif
    
    ! Get information about dimensions. Curtain mode or lat/lon mode?
    Llat  =.false.
    Llon  =.false.
    Lpoint=.false.
    errst = nf90_inquire(ncid, ndims, nvars, ngatts, recdim)
    if (errst /= 0) then
       errmsg="Error in  nf90_inquire"
       call cosp_error(routine_name,errmsg,errcode=errst)
    endif
    do i = 1,ndims
       errst = nf90_Inquire_Dimension(ncid,i,name=dimname(i),len=dimsize(i))
       if (errst /= 0) then
          write(straux, *)  i
          errmsg="Error in nf90_Inquire_Dimension, i: "//trim(straux)
          call cosp_error(routine_name,errmsg)
       endif
       if ((trim(dimname(i)).eq.'level').and.(Nlevels > dimsize(i))) then
          errmsg='Number of levels selected is greater than in input file '//trim(fname)
          call cosp_error(routine_name,errmsg)
       endif
       if (trim(dimname(i)).eq.'point') then
          Lpoint = .true.
          if (Npnts > dimsize(i)) then
             errmsg='Number of points selected is greater than in input file '//trim(fname)
             call cosp_error(routine_name,errmsg)
          endif
       endif
       if (trim(dimname(i)).eq.'lon') then
          Llon = .true.
          Nlon = dimsize(i)
       endif
       if (trim(dimname(i)).eq.'lat') then
          Llat = .true.
          Nlat = dimsize(i)
       endif
    enddo
    
    ! Get lon and lat
    if (Llon.and.Llat) then ! 2D mode
       if ((Npnts) > Nlon*Nlat) Npoints=Nlon*Nlat
       lon = -1.0E30
       lat = -1.0E30
       mode = 2 ! Don't know yet if (lon,lat) or (lat,lon) at this point
    else if (Lpoint) then ! 1D mode
       Nlon = Npoints
       Nlat = Npoints
       mode = 1
    else
       errmsg= trim(fname)//' file contains wrong dimensions'
       call cosp_error(routine_name,errmsg)
    endif
    errst = nf90_inq_varid(ncid, 'lon', vid)
    if (errst /= 0) then
       errmsg="Error in nf90_inq_varid, var: lon"
       call cosp_error(routine_name,errmsg,errcode=errst)
    endif
    errst = nf90_get_var(ncid, vid, lon, start = (/1/), count = (/Nlon/))
    if (errst /= 0) then
       errmsg="Error in nf90_get_var, var: lon"
       call cosp_error(routine_name,errmsg,errcode=errst)
    endif
    errst = nf90_inq_varid(ncid, 'lat', vid)
    if (errst /= 0) then
       errmsg="Error in nf90_inq_varid, var: lat"
       call cosp_error(routine_name,errmsg,errcode=errst)
    endif
    errst = nf90_get_var(ncid, vid, lat, start = (/1/), count = (/Nlat/))
    if (errst /= 0) then
       errmsg="Error in nf90_get_var, var: lat"
       call cosp_error(routine_name,errmsg,errcode=errst)
    endif
    
    ! Get all variables
    do vid = 1,nvars
       vdimid=0
       errst = nf90_Inquire_Variable(ncid, vid, name=vname, ndims=vrank, dimids=vdimid)
       if (errst /= 0) then
          write(straux, *)  vid
          errmsg='Error in nf90_Inquire_Variable, vid '//trim(straux)
          call cosp_error(routine_name,errmsg,errcode=errst)
       endif
       ! Read in into temporary array of correct shape
       if (vrank == 1) then
          Na = dimsize(vdimid(1))
          allocate(x1(Na))
          errst = nf90_get_var(ncid, vid, x1, start=(/1/), count=(/Na/))
       endif
       if (vrank == 2) then
          Na = dimsize(vdimid(1))
          Nb = dimsize(vdimid(2))
          allocate(x2(Na,Nb))
          errst = nf90_get_var(ncid, vid, x2, start=(/1,1/), count=(/Na,Nb/))
       endif
       if (vrank == 3) then
          Na = dimsize(vdimid(1))
          Nb = dimsize(vdimid(2))
          Nc = dimsize(vdimid(3))
          allocate(x3(Na,Nb,Nc))
          errst = nf90_get_var(ncid, vid, x3, start=(/1,1,1/), count=(/Na,Nb,Nc/))
          if ((mode == 2).or.(mode == 3)) then
             if ((Na == Nlon).and.(Nb == Nlat)) then
                mode = 2
             else if ((Na == Nlat).and.(Nb == Nlon)) then
                mode = 3
             else
                errmsg='Wrong mode for variable '//trim(vname)
                call cosp_error(routine_name,errmsg)
             endif
          endif
       endif
       if (vrank == 4) then
          Na = dimsize(vdimid(1))
          Nb = dimsize(vdimid(2))
          Nc = dimsize(vdimid(3))
          Nd = dimsize(vdimid(4))
          allocate(x4(Na,Nb,Nc,Nd))
          errst = nf90_get_var(ncid, vid, x4, start=(/1,1,1,1/), count=(/Na,Nb,Nc,Nd/))
       endif
       if (vrank == 5) then
          Na = dimsize(vdimid(1))
          Nb = dimsize(vdimid(2))
          Nc = dimsize(vdimid(3))
          Nd = dimsize(vdimid(4))
          Ne = dimsize(vdimid(5))
          allocate(x5(Na,Nb,Nc,Nd,Ne))
          errst = nf90_get_var(ncid, vid, x5, start=(/1,1,1,1,1/), count=(/Na,Nb,Nc,Nd,Ne/))
       endif
       if (errst /= 0) then
          write(straux, *)  vid
          errmsg='Error in nf90_get_var, vid '//trim(straux)
          call cosp_error(routine_name,errmsg,errcode=errst)
       endif
       ! Map to the right input argument
       select case (trim(vname))
       case ('pfull')
          if (Lpoint) then
             p(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=p)
          endif
       case ('phalf')
          if (Lpoint) then
             ph(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=ph)
          endif
       case ('height')
          if (Lpoint) then
             z(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=z)
          endif
       case ('height_half')
          if (Lpoint) then
             zh(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=zh)
          endif
       case ('T_abs')
          if (Lpoint) then
             T(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=T)
          endif
       case ('qv')
          if (Lpoint) then
             qv(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=qv)
          endif
       case ('rh')
          if (Lpoint) then
             rh(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=rh)
          endif
       case ('tca')
          if (Lpoint) then
             tca(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=tca)
          endif
          tca = tca
       case ('cca')
          if (Lpoint) then
             cca(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=cca)
          endif
          cca = cca
       case ('mr_lsliq')
          if (Lpoint) then
             mr_lsliq(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=mr_lsliq)
          endif
       case ('mr_lsice')
          if (Lpoint) then
             mr_lsice(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=mr_lsice)
          endif
       case ('mr_ccliq')
          if (Lpoint) then
             mr_ccliq(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=mr_ccliq)
          endif
       case ('mr_ccice')
          if (Lpoint) then
             mr_ccice(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=mr_ccice)
          endif
       case ('fl_lsrain')
          if (Lpoint) then
             fl_lsrain(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=fl_lsrain)
          endif
       case ('fl_lssnow')
          if (Lpoint) then
             fl_lssnow(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=fl_lssnow)
          endif
       case ('fl_lsgrpl')
          if (Lpoint) then
             fl_lsgrpl(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=fl_lsgrpl)
          endif
       case ('fl_ccrain')
          if (Lpoint) then
             fl_ccrain(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=fl_ccrain)
          endif
       case ('fl_ccsnow')
          if (Lpoint) then
             fl_ccsnow(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=fl_ccsnow)
          endif
       case ('dtau_s')
          if (Lpoint) then
             dtau_s(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=dtau_s)
          endif
       case ('dtau_c')
          if (Lpoint) then
             dtau_c(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=dtau_c)
          endif
       case ('dem_s')
          if (Lpoint) then
             dem_s(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=dem_s)
          endif
       case ('dem_c')
          if (Lpoint) then
             dem_c(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=dem_c)
          endif
       case ('Reff')
          if (Lpoint) then
             Reff(1:Npoints,:,:) = x3(1:Npoints,1:Nlevels,:)
          else
             call map_ll_to_point(Na,Nb,Npoints,x4=x4,y3=Reff)
          endif
       case ('skt')
          if (Lpoint) then
             skt(1:Npoints) = x1(1:Npoints)
          else
             call map_ll_to_point(Na,Nb,Npoints,x2=x2,y1=skt)
          endif
       case ('landmask')
          if (Lpoint) then
             landmask(1:Npoints) = x1(1:Npoints)
          else
             call map_ll_to_point(Na,Nb,Npoints,x2=x2,y1=landmask)
          endif
       case ('mr_ozone')
          if (Lpoint) then
             mr_ozone(1:Npoints,:) = x2(1:Npoints,1:Nlevels)
          else
             call map_ll_to_point(Na,Nb,Npoints,x3=x3,y2=mr_ozone)
          endif
       case ('u_wind')
          if (Lpoint) then
             u_wind(1:Npoints) = x1(1:Npoints)
          else
             call map_ll_to_point(Na,Nb,Npoints,x2=x2,y1=u_wind)
          endif
       case ('v_wind')
          if (Lpoint) then
             v_wind(1:Npoints) = x1(1:Npoints)
          else
             call map_ll_to_point(Na,Nb,Npoints,x2=x2,y1=v_wind)
          endif
       case ('sunlit')
          if (Lpoint) then
             sunlit(1:Npoints) = x1(1:Npoints)
          else
             call map_ll_to_point(Na,Nb,Npoints,x2=x2,y1=sunlit)
          endif
       end select
       ! Free memory
       if (vrank == 1) deallocate(x1)
       if (vrank == 2) deallocate(x2)
       if (vrank == 3) deallocate(x3)
       if (vrank == 4) deallocate(x4)
       if (vrank == 5) deallocate(x5)
    enddo
    
    ! SFC emissivity
    errst = nf90_inq_varid(ncid, 'emsfc_lw', vid)
    if (errst /= 0) then
       if (errst == nf90_enotvar) then ! Does not exist, use 1.0
          emsfc_lw = 1.0
          print *, ' ********* COSP Warning:  emsfc_lw does not exist in input file. Set to 1.0.'
       else  ! Other error, stop
          errmsg='Error in nf90_inq_varid, var: emsfc_lw'
          call cosp_error(routine_name,errmsg,errcode=errst)
       endif
    else
       errst = nf90_get_var(ncid, vid, emsfc_lw)
       if (errst /= 0) then
          errmsg='Error in nf90_get_var, var: emsfc_lw'
          call cosp_error(routine_name,errmsg,errcode=errst)
       endif
    endif
    
    
    ! Fill in the lat/lon vectors with the right values for 2D modes
    ! This might be helpful if the inputs are 2D (gridded) and 
    ! you want outputs in 1D mode
    allocate(plon(Npoints),plat(Npoints))
    if (mode == 2) then !(lon,lat)
       ll = lat
       do j=1,Nb
          do i=1,Na
             k = (j-1)*Na + i
             plon(k) = i  
             plat(k) = j
          enddo
       enddo
       lon(1:Npoints) = lon(plon(1:Npoints))
       lat(1:Npoints) = ll(plat(1:Npoints))
    else if (mode == 3) then !(lat,lon)
       ll = lon
       do j=1,Nb
          do i=1,Na
             k = (j-1)*Na + i
             lon(k) = ll(j)
             lat(k) = lat(i)
          enddo
       enddo
       lon(1:Npoints) = ll(plon(1:Npoints))
       lat(1:Npoints) = lat(plat(1:Npoints))
    endif
    deallocate(plon,plat)
    
    ! Close file
    errst = nf90_close(ncid)
    if (errst /= 0) then
       errmsg='Error in nf90_close'
       call cosp_error(routine_name,errmsg,errcode=errst)
    endif 
  END SUBROUTINE NC_READ_INPUT_FILE

   !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ! SUBROUTINE map_ll_to_point
  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  SUBROUTINE MAP_LL_TO_POINT(Nx,Ny,Np,x2,x3,x4,x5,y1,y2,y3,y4)
    ! Input arguments
    integer,intent(in) :: Nx,Ny,Np
    real(wp),intent(in),optional :: x2(:,:),x3(:,:,:), &
         x4(:,:,:,:),x5(:,:,:,:,:)
    real(wp),intent(out),optional :: y1(:),y2(:,:),y3(:,:,:), &
         y4(:,:,:,:)
    ! Local variables
    integer :: px(Nx*Ny),py(Nx*Ny)
    integer :: i,j,k,l,m
    integer :: Ni,Nj,Nk,Nl,Nm
    integer :: Mi,Mj,Mk,Ml
    character(len=128) :: proname='MAP_LL_TO_POINT'
    
    px=0
    py=0
    if (Nx*Ny < Np) then
       print *, ' -- '//trim(proname)//': Nx*Ny < Np'
       stop
    endif
    do j=1,Ny
       do i=1,Nx
          k = (j-1)*Nx+i
          px(k) = i  
          py(k) = j  
       enddo
    enddo
    
    if (present(x2).and.present(y1)) then
       Ni = size(x2,1)
       Nj = size(x2,2)
       Mi = size(y1,1)
       if (Ni*Nj < Mi) then
          print *, ' -- '//trim(proname)//': Nlon*Nlat < Npoints (opt 1)'
          stop
       endif
       do j=1,Np
          y1(j) = x2(px(j),py(j))
       enddo
    else if (present(x3).and.present(y2)) then
       Ni = size(x3,1)
       Nj = size(x3,2)
       Nk = size(x3,3)
       Mi = size(y2,1)
       Mj = size(y2,2)
       if (Ni*Nj < Mi) then
          print *, ' -- '//trim(proname)//': Nlon*Nlat < Npoints (opt 2)'
          stop
       endif
       if (Nk /= Mj) then
          print *, ' -- '//trim(proname)//': Nk /= Mj (opt 2)'
          stop
       endif
       do k=1,Nk
          do j=1,Np
             y2(j,k) = x3(px(j),py(j),k)
          enddo
       enddo
    else if (present(x4).and.present(y3)) then
       Ni = size(x4,1)
       Nj = size(x4,2)
       Nk = size(x4,3)
       Nl = size(x4,4)
       Mi = size(y3,1)
       Mj = size(y3,2)
       Mk = size(y3,3)
       if (Ni*Nj < Mi) then
          print *, ' -- '//trim(proname)//': Nlon*Nlat < Npoints (opt 3)'
          stop
       endif
       if (Nk /= Mj) then
          print *, ' -- '//trim(proname)//': Nk /= Mj (opt 3)'
          stop
       endif
       if (Nl /= Mk) then
          print *, ' -- '//trim(proname)//': Nl /= Mk (opt 3)'
          stop
       endif
       do l=1,Nl
          do k=1,Nk
             do j=1,Np
                y3(j,k,l) = x4(px(j),py(j),k,l)
             enddo
          enddo
       enddo
    else if (present(x5).and.present(y4)) then
       Ni = size(x5,1)
       Nj = size(x5,2)
       Nk = size(x5,3)
       Nl = size(x5,4)
       Nm = size(x5,5)
       Mi = size(y4,1)
       Mj = size(y4,2)
       Mk = size(y4,3)
       Ml = size(y4,4)
       if (Ni*Nj < Mi) then
          print *, ' -- '//trim(proname)//': Nlon*Nlat < Npoints (opt 4)'
          stop
       endif
       if (Nk /= Mj) then
          print *, ' -- '//trim(proname)//': Nk /= Mj (opt 4)'
          stop
       endif
       if (Nl /= Mk) then
          print *, ' -- '//trim(proname)//': Nl /= Mk (opt 4)'
          stop
       endif
       if (Nm /= Ml) then
          print *, ' -- '//trim(proname)//': Nm /= Ml (opt 4)'
          stop
       endif
       do m=1,Nm
          do l=1,Nl
             do k=1,Nk
                do j=1,Np
                   y4(j,k,l,m) = x5(px(j),py(j),k,l,m)
                enddo
             enddo
          enddo
       enddo
    else
       print *, ' -- '//trim(proname)//': wrong option'
       stop
    endif 
  END SUBROUTINE MAP_LL_TO_POINT
  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ! Subrotuine cosp_error
  !%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  SUBROUTINE COSP_ERROR(routine_name,message,errcode) 
    character(len = *), intent(in) :: routine_name
    character(len = *), intent(in) :: message
    integer,optional :: errcode
    
    write(6, *) " ********** Failure in ", trim(routine_name)
    write(6, *) " ********** ", trim(message)
    if (present(errcode)) write(6, *) " ********** errcode: ", errcode
    flush(6)
    stop
  END SUBROUTINE COSP_ERROR
  end module mod_cosp_io
