#
# (C) Copyright 2025 Advanced Micro Devices, Inc. All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#

    proc axi_mmi_dc_generate {drv_handle} {
        # Generate properties required for mmi dc node
        set node [get_node $drv_handle]
        if {$node == 0} {
           return
        }
        set dts_file [set_drv_def_dts $drv_handle]

        set operating_mode [hsi get_property CONFIG.C_DPDC_OPERATING_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-operating-mode" $operating_mode string $dts_file
        set pres_mode [hsi get_property CONFIG.C_DPDC_PRESENTATION_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-presentation-mode" $pres_mode string $dts_file

        set video_sel [hsi get_property CONFIG.C_DC_LIVE_VIDEO_SELECT [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-live-video-select" $video_sel string $dts_file

        set video1_mode [hsi get_property CONFIG.C_DC_LIVE_VIDEO01_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-live-video01-mode" $video1_mode string $dts_file

        set video2_mode [hsi get_property CONFIG.C_DC_LIVE_VIDEO02_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-live-video02-mode" $video2_mode string $dts_file

        set alpha_en [hsi get_property CONFIG.C_DC_LIVE_VIDEO_ALPHA_EN [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-live-video-alpha-en" $alpha_en int $dts_file

        set video_sdp_en [hsi get_property CONFIG.C_DC_LIVE_VIDEO_SDP_EN [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-live-video-sdp-en" $video_sdp_en int $dts_file

        set streams [hsi get_property CONFIG.C_DPDC_STREAMS [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-streams" $streams int $dts_file

        set stream0_mode [hsi get_property CONFIG.C_DPDC_STREAM0_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream0-mode" $stream0_mode string $dts_file

        set stream0_pixel_mode [hsi get_property CONFIG.C_DPDC_STREAM0_PIXEL_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream0-pixel-mode" $stream0_pixel_mode string $dts_file

        set stream0_sdp_en [hsi get_property CONFIG.C_DPDC_STREAM0_SDP_EN [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream0-sdp-en" $stream0_sdp_en int $dts_file

        set stream1_mode [hsi get_property CONFIG.C_DPDC_STREAM1_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream1-mode" $stream1_mode string $dts_file

        set stream1_pixel_modde [hsi get_property CONFIG.C_DPDC_STREAM1_PIXEL_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream1-pixel-mode" $stream1_pixel_modde string $dts_file

        set stream1_sdp_en [hsi get_property CONFIG.C_DPDC_STREAM1_SDP_EN [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream1-sdp-en" $stream1_sdp_en int $dts_file

        set stream2_mode [hsi get_property CONFIG.C_DPDC_STREAM2_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream2-mode" $stream2_mode string $dts_file

        set stream2_pixel_mode [hsi get_property CONFIG.C_DPDC_STREAM2_PIXEL_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream2-pixel-mode" $stream2_pixel_mode string $dts_file

        set stream2_sdp_en [hsi get_property CONFIG.C_DPDC_STREAM2_SDP_EN [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream2-sdp-en" $stream2_sdp_en int $dts_file

        set stream3_mode [hsi get_property CONFIG.C_DPDC_STREAM3_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream3-mode" $stream3_mode string $dts_file

        set stream3_pixel_mode [hsi get_property CONFIG.C_DPDC_STREAM3_PIXEL_MODE [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream3-pixel-mode" $stream3_pixel_mode string $dts_file

        set stream3_sdp_en [hsi get_property CONFIG.C_DPDC_STREAM3_SDP_EN [hsi::get_cells -hier -filter IP_NAME==mmi_dc]]
        add_prop $node "xlnx,dc-stream3-sdp-en" $stream3_sdp_en int $dts_file

	set dcdma_node [create_node -n "&mmi_dcdma" -d "pcw.dtsi" -p root -h $drv_handle]
	add_prop $dcdma_node "status" "okay" string $dts_file
    }
