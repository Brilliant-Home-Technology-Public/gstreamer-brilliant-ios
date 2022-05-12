/*****************************************************************************
 * GStreamer-Brilliant: Dynamic XCFramework built with system's GStreamer Implementation. Intended for use in Brilliant Mobile App.
 *****************************************************************************
 * Copyright (C) 2022 Brilliant Home Technologies
 *
 * Authors: Brilliant iOS Team <apple_developer # brilliant.tech>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <Foundation/Foundation.h>
#include "gst_ios_init.h"

#include <gio/gio.h>

#if defined(GST_IOS_PLUGIN_COREELEMENTS) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(coreelements);
#endif
#if defined(GST_IOS_PLUGIN_CORETRACERS) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(coretracers);
#endif
#if defined(GST_IOS_PLUGIN_ADDER) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(adder);
#endif
#if defined(GST_IOS_PLUGIN_APP) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(app);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOCONVERT) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(audioconvert);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOMIXER) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(audiomixer);
#endif
#if defined(GST_IOS_PLUGIN_AUDIORATE) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(audiorate);
#endif
#if defined(GST_IOS_PLUGIN_AUDIORESAMPLE) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(audioresample);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOTESTSRC) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(audiotestsrc);
#endif
#if defined(GST_IOS_PLUGIN_COMPOSITOR) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(compositor);
#endif
#if defined(GST_IOS_PLUGIN_GIO) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(gio);
#endif
#if defined(GST_IOS_PLUGIN_OVERLAYCOMPOSITION) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(overlaycomposition);
#endif
#if defined(GST_IOS_PLUGIN_PANGO) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(pango);
#endif
#if defined(GST_IOS_PLUGIN_RAWPARSE) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(rawparse);
#endif
#if defined(GST_IOS_PLUGIN_TYPEFINDFUNCTIONS) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(typefindfunctions);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOCONVERT) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(videoconvert);
#endif
#if defined(GST_IOS_PLUGIN_VIDEORATE) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(videorate);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOSCALE) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(videoscale);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOTESTSRC) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(videotestsrc);
#endif
#if defined(GST_IOS_PLUGIN_VOLUME) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(volume);
#endif
#if defined(GST_IOS_PLUGIN_AUTODETECT) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(autodetect);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOFILTER) || defined(GST_IOS_PLUGINS_CORE)
GST_PLUGIN_STATIC_DECLARE(videofilter);
#endif
#if defined(GST_IOS_PLUGIN_SUBPARSE) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(subparse);
#endif
#if defined(GST_IOS_PLUGIN_OGG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(ogg);
#endif
#if defined(GST_IOS_PLUGIN_THEORA) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(theora);
#endif
#if defined(GST_IOS_PLUGIN_VORBIS) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(vorbis);
#endif
#if defined(GST_IOS_PLUGIN_OPUS) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(opus);
#endif
#if defined(GST_IOS_PLUGIN_IVORBISDEC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(ivorbisdec);
#endif
#if defined(GST_IOS_PLUGIN_ALAW) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(alaw);
#endif
#if defined(GST_IOS_PLUGIN_APETAG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(apetag);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOPARSERS) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(audioparsers);
#endif
#if defined(GST_IOS_PLUGIN_AUPARSE) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(auparse);
#endif
#if defined(GST_IOS_PLUGIN_AVI) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(avi);
#endif
#if defined(GST_IOS_PLUGIN_DV) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(dv);
#endif
#if defined(GST_IOS_PLUGIN_FLAC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(flac);
#endif
#if defined(GST_IOS_PLUGIN_FLV) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(flv);
#endif
#if defined(GST_IOS_PLUGIN_FLXDEC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(flxdec);
#endif
#if defined(GST_IOS_PLUGIN_ICYDEMUX) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(icydemux);
#endif
#if defined(GST_IOS_PLUGIN_ID3DEMUX) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(id3demux);
#endif
#if defined(GST_IOS_PLUGIN_ISOMP4) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(isomp4);
#endif
#if defined(GST_IOS_PLUGIN_JPEG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(jpeg);
#endif
#if defined(GST_IOS_PLUGIN_LAME) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(lame);
#endif
#if defined(GST_IOS_PLUGIN_MATROSKA) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(matroska);
#endif
#if defined(GST_IOS_PLUGIN_MPG123) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(mpg123);
#endif
#if defined(GST_IOS_PLUGIN_MULAW) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(mulaw);
#endif
#if defined(GST_IOS_PLUGIN_MULTIPART) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(multipart);
#endif
#if defined(GST_IOS_PLUGIN_PNG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(png);
#endif
#if defined(GST_IOS_PLUGIN_SPEEX) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(speex);
#endif
#if defined(GST_IOS_PLUGIN_TAGLIB) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(taglib);
#endif
#if defined(GST_IOS_PLUGIN_VPX) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(vpx);
#endif
#if defined(GST_IOS_PLUGIN_WAVENC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(wavenc);
#endif
#if defined(GST_IOS_PLUGIN_WAVPACK) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(wavpack);
#endif
#if defined(GST_IOS_PLUGIN_WAVPARSE) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(wavparse);
#endif
#if defined(GST_IOS_PLUGIN_Y4MENC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(y4menc);
#endif
#if defined(GST_IOS_PLUGIN_ADPCMDEC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(adpcmdec);
#endif
#if defined(GST_IOS_PLUGIN_ADPCMENC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(adpcmenc);
#endif
#if defined(GST_IOS_PLUGIN_ASSRENDER) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(assrender);
#endif
#if defined(GST_IOS_PLUGIN_BZ2) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(bz2);
#endif
#if defined(GST_IOS_PLUGIN_DASH) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(dash);
#endif
#if defined(GST_IOS_PLUGIN_DVBSUBOVERLAY) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(dvbsuboverlay);
#endif
#if defined(GST_IOS_PLUGIN_DVDSPU) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(dvdspu);
#endif
#if defined(GST_IOS_PLUGIN_HLS) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(hls);
#endif
#if defined(GST_IOS_PLUGIN_ID3TAG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(id3tag);
#endif
#if defined(GST_IOS_PLUGIN_KATE) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(kate);
#endif
#if defined(GST_IOS_PLUGIN_MIDI) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(midi);
#endif
#if defined(GST_IOS_PLUGIN_MXF) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(mxf);
#endif
#if defined(GST_IOS_PLUGIN_OPENH264) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(openh264);
#endif
#if defined(GST_IOS_PLUGIN_OPUSPARSE) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(opusparse);
#endif
#if defined(GST_IOS_PLUGIN_PCAPPARSE) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(pcapparse);
#endif
#if defined(GST_IOS_PLUGIN_PNM) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(pnm);
#endif
#if defined(GST_IOS_PLUGIN_RFBSRC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(rfbsrc);
#endif
#if defined(GST_IOS_PLUGIN_SIREN) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(siren);
#endif
#if defined(GST_IOS_PLUGIN_SMOOTHSTREAMING) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(smoothstreaming);
#endif
#if defined(GST_IOS_PLUGIN_SUBENC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(subenc);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOPARSERSBAD) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(videoparsersbad);
#endif
#if defined(GST_IOS_PLUGIN_Y4MDEC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(y4mdec);
#endif
#if defined(GST_IOS_PLUGIN_JPEGFORMAT) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(jpegformat);
#endif
#if defined(GST_IOS_PLUGIN_GDP) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(gdp);
#endif
#if defined(GST_IOS_PLUGIN_RSVG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(rsvg);
#endif
#if defined(GST_IOS_PLUGIN_OPENJPEG) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(openjpeg);
#endif
#if defined(GST_IOS_PLUGIN_SPANDSP) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(spandsp);
#endif
#if defined(GST_IOS_PLUGIN_SBC) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(sbc);
#endif
#if defined(GST_IOS_PLUGIN_ZBAR) || defined(GST_IOS_PLUGINS_CODECS)
GST_PLUGIN_STATIC_DECLARE(zbar);
#endif
#if defined(GST_IOS_PLUGIN_ENCODING) || defined(GST_IOS_PLUGINS_ENCODING)
GST_PLUGIN_STATIC_DECLARE(encoding);
#endif
#if defined(GST_IOS_PLUGIN_TCP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(tcp);
#endif
#if defined(GST_IOS_PLUGIN_RTSP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rtsp);
#endif
#if defined(GST_IOS_PLUGIN_RTP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rtp);
#endif
#if defined(GST_IOS_PLUGIN_RTPMANAGER) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rtpmanager);
#endif
#if defined(GST_IOS_PLUGIN_SOUP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(soup);
#endif
#if defined(GST_IOS_PLUGIN_UDP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(udp);
#endif
#if defined(GST_IOS_PLUGIN_DTLS) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(dtls);
#endif
#if defined(GST_IOS_PLUGIN_NETSIM) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(netsim);
#endif
#if defined(GST_IOS_PLUGIN_RIST) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rist);
#endif
#if defined(GST_IOS_PLUGIN_RTMP2) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rtmp2);
#endif
#if defined(GST_IOS_PLUGIN_RTPMANAGERBAD) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rtpmanagerbad);
#endif
#if defined(GST_IOS_PLUGIN_SCTP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(sctp);
#endif
#if defined(GST_IOS_PLUGIN_SDPELEM) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(sdpelem);
#endif
#if defined(GST_IOS_PLUGIN_SRTP) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(srtp);
#endif
#if defined(GST_IOS_PLUGIN_SRT) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(srt);
#endif
#if defined(GST_IOS_PLUGIN_WEBRTC) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(webrtc);
#endif
#if defined(GST_IOS_PLUGIN_NICE) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(nice);
#endif
#if defined(GST_IOS_PLUGIN_RTSPCLIENTSINK) || defined(GST_IOS_PLUGINS_NET)
GST_PLUGIN_STATIC_DECLARE(rtspclientsink);
#endif
#if defined(GST_IOS_PLUGIN_PLAYBACK) || defined(GST_IOS_PLUGINS_PLAYBACK)
GST_PLUGIN_STATIC_DECLARE(playback);
#endif
#if defined(GST_IOS_PLUGIN_OPENGL) || defined(GST_IOS_PLUGINS_SYS)
GST_PLUGIN_STATIC_DECLARE(opengl);
#endif
#if defined(GST_IOS_PLUGIN_OSXAUDIO) || defined(GST_IOS_PLUGINS_SYS)
GST_PLUGIN_STATIC_DECLARE(osxaudio);
#endif
#if defined(GST_IOS_PLUGIN_IPCPIPELINE) || defined(GST_IOS_PLUGINS_SYS)
GST_PLUGIN_STATIC_DECLARE(ipcpipeline);
#endif
#if defined(GST_IOS_PLUGIN_APPLEMEDIA) || defined(GST_IOS_PLUGINS_SYS)
GST_PLUGIN_STATIC_DECLARE(applemedia);
#endif
#if defined(GST_IOS_PLUGIN_SHM) || defined(GST_IOS_PLUGINS_SYS)
GST_PLUGIN_STATIC_DECLARE(shm);
#endif
#if defined(GST_IOS_PLUGIN_ALPHA) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(alpha);
#endif
#if defined(GST_IOS_PLUGIN_ALPHACOLOR) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(alphacolor);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOFX) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(audiofx);
#endif
#if defined(GST_IOS_PLUGIN_CAIRO) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(cairo);
#endif
#if defined(GST_IOS_PLUGIN_CUTTER) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(cutter);
#endif
#if defined(GST_IOS_PLUGIN_DEBUG) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(debug);
#endif
#if defined(GST_IOS_PLUGIN_DEINTERLACE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(deinterlace);
#endif
#if defined(GST_IOS_PLUGIN_DTMF) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(dtmf);
#endif
#if defined(GST_IOS_PLUGIN_EFFECTV) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(effectv);
#endif
#if defined(GST_IOS_PLUGIN_EQUALIZER) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(equalizer);
#endif
#if defined(GST_IOS_PLUGIN_GDKPIXBUF) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(gdkpixbuf);
#endif
#if defined(GST_IOS_PLUGIN_IMAGEFREEZE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(imagefreeze);
#endif
#if defined(GST_IOS_PLUGIN_INTERLEAVE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(interleave);
#endif
#if defined(GST_IOS_PLUGIN_LEVEL) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(level);
#endif
#if defined(GST_IOS_PLUGIN_MULTIFILE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(multifile);
#endif
#if defined(GST_IOS_PLUGIN_REPLAYGAIN) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(replaygain);
#endif
#if defined(GST_IOS_PLUGIN_SHAPEWIPE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(shapewipe);
#endif
#if defined(GST_IOS_PLUGIN_SMPTE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(smpte);
#endif
#if defined(GST_IOS_PLUGIN_SPECTRUM) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(spectrum);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOBOX) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(videobox);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOCROP) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(videocrop);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOMIXER) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(videomixer);
#endif
#if defined(GST_IOS_PLUGIN_ACCURIP) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(accurip);
#endif
#if defined(GST_IOS_PLUGIN_AIFF) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(aiff);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOBUFFERSPLIT) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(audiobuffersplit);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOFXBAD) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(audiofxbad);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOLATENCY) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(audiolatency);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOMIXMATRIX) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(audiomixmatrix);
#endif
#if defined(GST_IOS_PLUGIN_AUTOCONVERT) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(autoconvert);
#endif
#if defined(GST_IOS_PLUGIN_BAYER) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(bayer);
#endif
#if defined(GST_IOS_PLUGIN_COLOREFFECTS) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(coloreffects);
#endif
#if defined(GST_IOS_PLUGIN_CLOSEDCAPTION) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(closedcaption);
#endif
#if defined(GST_IOS_PLUGIN_DEBUGUTILSBAD) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(debugutilsbad);
#endif
#if defined(GST_IOS_PLUGIN_FIELDANALYSIS) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(fieldanalysis);
#endif
#if defined(GST_IOS_PLUGIN_FREEVERB) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(freeverb);
#endif
#if defined(GST_IOS_PLUGIN_FREI0R) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(frei0r);
#endif
#if defined(GST_IOS_PLUGIN_GAUDIEFFECTS) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(gaudieffects);
#endif
#if defined(GST_IOS_PLUGIN_GEOMETRICTRANSFORM) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(geometrictransform);
#endif
#if defined(GST_IOS_PLUGIN_INTER) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(inter);
#endif
#if defined(GST_IOS_PLUGIN_INTERLACE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(interlace);
#endif
#if defined(GST_IOS_PLUGIN_IVTC) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(ivtc);
#endif
#if defined(GST_IOS_PLUGIN_LEGACYRAWPARSE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(legacyrawparse);
#endif
#if defined(GST_IOS_PLUGIN_PROXY) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(proxy);
#endif
#if defined(GST_IOS_PLUGIN_REMOVESILENCE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(removesilence);
#endif
#if defined(GST_IOS_PLUGIN_SEGMENTCLIP) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(segmentclip);
#endif
#if defined(GST_IOS_PLUGIN_SMOOTH) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(smooth);
#endif
#if defined(GST_IOS_PLUGIN_SPEED) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(speed);
#endif
#if defined(GST_IOS_PLUGIN_SOUNDTOUCH) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(soundtouch);
#endif
#if defined(GST_IOS_PLUGIN_TIMECODE) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(timecode);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOFILTERSBAD) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(videofiltersbad);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOFRAME_AUDIOLEVEL) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(videoframe_audiolevel);
#endif
#if defined(GST_IOS_PLUGIN_WEBRTCDSP) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(webrtcdsp);
#endif
#if defined(GST_IOS_PLUGIN_LADSPA) || defined(GST_IOS_PLUGINS_EFFECTS)
GST_PLUGIN_STATIC_DECLARE(ladspa);
#endif
#if defined(GST_IOS_PLUGIN_GOOM) || defined(GST_IOS_PLUGINS_VIS)
GST_PLUGIN_STATIC_DECLARE(goom);
#endif
#if defined(GST_IOS_PLUGIN_GOOM2K1) || defined(GST_IOS_PLUGINS_VIS)
GST_PLUGIN_STATIC_DECLARE(goom2k1);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOVISUALIZERS) || defined(GST_IOS_PLUGINS_VIS)
GST_PLUGIN_STATIC_DECLARE(audiovisualizers);
#endif
#if defined(GST_IOS_PLUGIN_CAMERABIN) || defined(GST_IOS_PLUGINS_CAPTURE)
GST_PLUGIN_STATIC_DECLARE(camerabin);
#endif
#if defined(GST_IOS_PLUGIN_ASFMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(asfmux);
#endif
#if defined(GST_IOS_PLUGIN_DTSDEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(dtsdec);
#endif
#if defined(GST_IOS_PLUGIN_MPEGPSDEMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(mpegpsdemux);
#endif
#if defined(GST_IOS_PLUGIN_MPEGPSMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(mpegpsmux);
#endif
#if defined(GST_IOS_PLUGIN_MPEGTSDEMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(mpegtsdemux);
#endif
#if defined(GST_IOS_PLUGIN_MPEGTSMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(mpegtsmux);
#endif
#if defined(GST_IOS_PLUGIN_VOAACENC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(voaacenc);
#endif
#if defined(GST_IOS_PLUGIN_A52DEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(a52dec);
#endif
#if defined(GST_IOS_PLUGIN_AMRNB) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(amrnb);
#endif
#if defined(GST_IOS_PLUGIN_AMRWBDEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(amrwbdec);
#endif
#if defined(GST_IOS_PLUGIN_ASF) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(asf);
#endif
#if defined(GST_IOS_PLUGIN_DVDSUB) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(dvdsub);
#endif
#if defined(GST_IOS_PLUGIN_DVDLPCMDEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(dvdlpcmdec);
#endif
#if defined(GST_IOS_PLUGIN_XINGMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(xingmux);
#endif
#if defined(GST_IOS_PLUGIN_REALMEDIA) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(realmedia);
#endif
#if defined(GST_IOS_PLUGIN_X264) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(x264);
#endif
#if defined(GST_IOS_PLUGIN_LIBAV) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(libav);
#endif
#if defined(GST_IOS_PLUGIN_RTMP) || defined(GST_IOS_PLUGINS_NET_RESTRICTED)
GST_PLUGIN_STATIC_DECLARE(rtmp);
#endif
#if defined(GST_IOS_PLUGIN_VULKAN) || defined(GST_IOS_PLUGINS_VULKAN)
GST_PLUGIN_STATIC_DECLARE(vulkan);
#endif
#if defined(GST_IOS_PLUGIN_NLE) || defined(GST_IOS_PLUGINS_GES)
GST_PLUGIN_STATIC_DECLARE(nle);
#endif
#if defined(GST_IOS_PLUGIN_GES) || defined(GST_IOS_PLUGINS_GES)
GST_PLUGIN_STATIC_DECLARE(ges);
#endif

#if defined(GST_IOS_GIO_MODULE_OPENSSL)
GST_G_IO_MODULE_DECLARE(openssl);
#endif

void
gst_ios_init (void)
{
  GstPluginFeature *plugin;
  GstRegistry *reg;
  NSString *resources = [[NSBundle mainBundle] resourcePath];
  NSString *tmp = NSTemporaryDirectory();
  NSString *cache = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
  NSString *docs = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
  
  const gchar *resources_dir = [resources UTF8String];
  const gchar *tmp_dir = [tmp UTF8String];
  const gchar *cache_dir = [cache UTF8String];
  const gchar *docs_dir = [docs UTF8String];
  gchar *ca_certificates;
  
  g_setenv ("TMP", tmp_dir, TRUE);
  g_setenv ("TEMP", tmp_dir, TRUE);
  g_setenv ("TMPDIR", tmp_dir, TRUE);
  g_setenv ("XDG_RUNTIME_DIR", resources_dir, TRUE);
  g_setenv ("XDG_CACHE_HOME", cache_dir, TRUE);
  
  g_setenv ("HOME", docs_dir, TRUE);
  g_setenv ("XDG_DATA_DIRS", resources_dir, TRUE);
  g_setenv ("XDG_CONFIG_DIRS", resources_dir, TRUE);
  g_setenv ("XDG_CONFIG_HOME", cache_dir, TRUE);
  g_setenv ("XDG_DATA_HOME", resources_dir, TRUE);
  g_setenv ("FONTCONFIG_PATH", resources_dir, TRUE);
  
  ca_certificates = g_build_filename (resources_dir, "ca-certificates.crt", NULL);
  GST_DEBUG("KIYOSHI - LOOKING FOR %s", ca_certificates);
  g_setenv ("CA_CERTIFICATES", ca_certificates, TRUE);
  
#if defined(GST_IOS_GIO_MODULE_OPENSSL)
  GST_G_IO_MODULE_LOAD(openssl);
#endif
  
  if (ca_certificates) {
    GTlsBackend *backend = g_tls_backend_get_default ();
    if (backend) {
      GTlsDatabase *db = g_tls_file_database_new (ca_certificates, NULL);
      if (db)
        g_tls_backend_set_default_database (backend, db);
    }
  }
  g_free (ca_certificates);
  
  gst_init (NULL, NULL);
  
#if defined(GST_IOS_PLUGIN_COREELEMENTS) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(coreelements);
#endif
#if defined(GST_IOS_PLUGIN_CORETRACERS) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(coretracers);
#endif
#if defined(GST_IOS_PLUGIN_ADDER) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(adder);
#endif
#if defined(GST_IOS_PLUGIN_APP) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(app);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOCONVERT) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(audioconvert);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOMIXER) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(audiomixer);
#endif
#if defined(GST_IOS_PLUGIN_AUDIORATE) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(audiorate);
#endif
#if defined(GST_IOS_PLUGIN_AUDIORESAMPLE) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(audioresample);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOTESTSRC) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(audiotestsrc);
#endif
#if defined(GST_IOS_PLUGIN_COMPOSITOR) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(compositor);
#endif
#if defined(GST_IOS_PLUGIN_GIO) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(gio);
#endif
#if defined(GST_IOS_PLUGIN_OVERLAYCOMPOSITION) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(overlaycomposition);
#endif
#if defined(GST_IOS_PLUGIN_PANGO) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(pango);
#endif
#if defined(GST_IOS_PLUGIN_RAWPARSE) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(rawparse);
#endif
#if defined(GST_IOS_PLUGIN_TYPEFINDFUNCTIONS) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(typefindfunctions);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOCONVERT) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(videoconvert);
#endif
#if defined(GST_IOS_PLUGIN_VIDEORATE) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(videorate);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOSCALE) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(videoscale);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOTESTSRC) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(videotestsrc);
#endif
#if defined(GST_IOS_PLUGIN_VOLUME) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(volume);
#endif
#if defined(GST_IOS_PLUGIN_AUTODETECT) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(autodetect);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOFILTER) || defined(GST_IOS_PLUGINS_CORE)
  GST_PLUGIN_STATIC_REGISTER(videofilter);
#endif
#if defined(GST_IOS_PLUGIN_SUBPARSE) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(subparse);
#endif
#if defined(GST_IOS_PLUGIN_OGG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(ogg);
#endif
#if defined(GST_IOS_PLUGIN_THEORA) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(theora);
#endif
#if defined(GST_IOS_PLUGIN_VORBIS) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(vorbis);
#endif
#if defined(GST_IOS_PLUGIN_OPUS) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(opus);
#endif
#if defined(GST_IOS_PLUGIN_IVORBISDEC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(ivorbisdec);
#endif
#if defined(GST_IOS_PLUGIN_ALAW) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(alaw);
#endif
#if defined(GST_IOS_PLUGIN_APETAG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(apetag);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOPARSERS) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(audioparsers);
#endif
#if defined(GST_IOS_PLUGIN_AUPARSE) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(auparse);
#endif
#if defined(GST_IOS_PLUGIN_AVI) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(avi);
#endif
#if defined(GST_IOS_PLUGIN_DV) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(dv);
#endif
#if defined(GST_IOS_PLUGIN_FLAC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(flac);
#endif
#if defined(GST_IOS_PLUGIN_FLV) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(flv);
#endif
#if defined(GST_IOS_PLUGIN_FLXDEC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(flxdec);
#endif
#if defined(GST_IOS_PLUGIN_ICYDEMUX) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(icydemux);
#endif
#if defined(GST_IOS_PLUGIN_ID3DEMUX) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(id3demux);
#endif
#if defined(GST_IOS_PLUGIN_ISOMP4) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(isomp4);
#endif
#if defined(GST_IOS_PLUGIN_JPEG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(jpeg);
#endif
#if defined(GST_IOS_PLUGIN_LAME) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(lame);
#endif
#if defined(GST_IOS_PLUGIN_MATROSKA) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(matroska);
#endif
#if defined(GST_IOS_PLUGIN_MPG123) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(mpg123);
#endif
#if defined(GST_IOS_PLUGIN_MULAW) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(mulaw);
#endif
#if defined(GST_IOS_PLUGIN_MULTIPART) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(multipart);
#endif
#if defined(GST_IOS_PLUGIN_PNG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(png);
#endif
#if defined(GST_IOS_PLUGIN_SPEEX) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(speex);
#endif
#if defined(GST_IOS_PLUGIN_TAGLIB) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(taglib);
#endif
#if defined(GST_IOS_PLUGIN_VPX) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(vpx);
#endif
#if defined(GST_IOS_PLUGIN_WAVENC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(wavenc);
#endif
#if defined(GST_IOS_PLUGIN_WAVPACK) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(wavpack);
#endif
#if defined(GST_IOS_PLUGIN_WAVPARSE) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(wavparse);
#endif
#if defined(GST_IOS_PLUGIN_Y4MENC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(y4menc);
#endif
#if defined(GST_IOS_PLUGIN_ADPCMDEC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(adpcmdec);
#endif
#if defined(GST_IOS_PLUGIN_ADPCMENC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(adpcmenc);
#endif
#if defined(GST_IOS_PLUGIN_ASSRENDER) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(assrender);
#endif
#if defined(GST_IOS_PLUGIN_BZ2) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(bz2);
#endif
#if defined(GST_IOS_PLUGIN_DASH) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(dash);
#endif
#if defined(GST_IOS_PLUGIN_DVBSUBOVERLAY) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(dvbsuboverlay);
#endif
#if defined(GST_IOS_PLUGIN_DVDSPU) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(dvdspu);
#endif
#if defined(GST_IOS_PLUGIN_HLS) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(hls);
#endif
#if defined(GST_IOS_PLUGIN_ID3TAG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(id3tag);
#endif
#if defined(GST_IOS_PLUGIN_KATE) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(kate);
#endif
#if defined(GST_IOS_PLUGIN_MIDI) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(midi);
#endif
#if defined(GST_IOS_PLUGIN_MXF) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(mxf);
#endif
#if defined(GST_IOS_PLUGIN_OPENH264) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(openh264);
#endif
#if defined(GST_IOS_PLUGIN_OPUSPARSE) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(opusparse);
#endif
#if defined(GST_IOS_PLUGIN_PCAPPARSE) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(pcapparse);
#endif
#if defined(GST_IOS_PLUGIN_PNM) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(pnm);
#endif
#if defined(GST_IOS_PLUGIN_RFBSRC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(rfbsrc);
#endif
#if defined(GST_IOS_PLUGIN_SIREN) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(siren);
#endif
#if defined(GST_IOS_PLUGIN_SMOOTHSTREAMING) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(smoothstreaming);
#endif
#if defined(GST_IOS_PLUGIN_SUBENC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(subenc);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOPARSERSBAD) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(videoparsersbad);
#endif
#if defined(GST_IOS_PLUGIN_Y4MDEC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(y4mdec);
#endif
#if defined(GST_IOS_PLUGIN_JPEGFORMAT) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(jpegformat);
#endif
#if defined(GST_IOS_PLUGIN_GDP) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(gdp);
#endif
#if defined(GST_IOS_PLUGIN_RSVG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(rsvg);
#endif
#if defined(GST_IOS_PLUGIN_OPENJPEG) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(openjpeg);
#endif
#if defined(GST_IOS_PLUGIN_SPANDSP) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(spandsp);
#endif
#if defined(GST_IOS_PLUGIN_SBC) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(sbc);
#endif
#if defined(GST_IOS_PLUGIN_ZBAR) || defined(GST_IOS_PLUGINS_CODECS)
  GST_PLUGIN_STATIC_REGISTER(zbar);
#endif
#if defined(GST_IOS_PLUGIN_ENCODING) || defined(GST_IOS_PLUGINS_ENCODING)
  GST_PLUGIN_STATIC_REGISTER(encoding);
#endif
#if defined(GST_IOS_PLUGIN_TCP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(tcp);
#endif
#if defined(GST_IOS_PLUGIN_RTSP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rtsp);
#endif
#if defined(GST_IOS_PLUGIN_RTP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rtp);
#endif
#if defined(GST_IOS_PLUGIN_RTPMANAGER) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rtpmanager);
#endif
#if defined(GST_IOS_PLUGIN_SOUP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(soup);
#endif
#if defined(GST_IOS_PLUGIN_UDP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(udp);
#endif
#if defined(GST_IOS_PLUGIN_DTLS) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(dtls);
#endif
#if defined(GST_IOS_PLUGIN_NETSIM) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(netsim);
#endif
#if defined(GST_IOS_PLUGIN_RIST) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rist);
#endif
#if defined(GST_IOS_PLUGIN_RTMP2) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rtmp2);
#endif
#if defined(GST_IOS_PLUGIN_RTPMANAGERBAD) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rtpmanagerbad);
#endif
#if defined(GST_IOS_PLUGIN_SCTP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(sctp);
#endif
#if defined(GST_IOS_PLUGIN_SDPELEM) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(sdpelem);
#endif
#if defined(GST_IOS_PLUGIN_SRTP) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(srtp);
#endif
#if defined(GST_IOS_PLUGIN_SRT) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(srt);
#endif
#if defined(GST_IOS_PLUGIN_WEBRTC) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(webrtc);
#endif
#if defined(GST_IOS_PLUGIN_NICE) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(nice);
#endif
#if defined(GST_IOS_PLUGIN_RTSPCLIENTSINK) || defined(GST_IOS_PLUGINS_NET)
  GST_PLUGIN_STATIC_REGISTER(rtspclientsink);
#endif
#if defined(GST_IOS_PLUGIN_PLAYBACK) || defined(GST_IOS_PLUGINS_PLAYBACK)
  GST_PLUGIN_STATIC_REGISTER(playback);
#endif
#if defined(GST_IOS_PLUGIN_OPENGL) || defined(GST_IOS_PLUGINS_SYS)
  GST_PLUGIN_STATIC_REGISTER(opengl);
#endif
#if defined(GST_IOS_PLUGIN_OSXAUDIO) || defined(GST_IOS_PLUGINS_SYS)
  GST_PLUGIN_STATIC_REGISTER(osxaudio);
#endif
#if defined(GST_IOS_PLUGIN_IPCPIPELINE) || defined(GST_IOS_PLUGINS_SYS)
  GST_PLUGIN_STATIC_REGISTER(ipcpipeline);
#endif
#if defined(GST_IOS_PLUGIN_APPLEMEDIA) || defined(GST_IOS_PLUGINS_SYS)
  GST_PLUGIN_STATIC_REGISTER(applemedia);
#endif
#if defined(GST_IOS_PLUGIN_SHM) || defined(GST_IOS_PLUGINS_SYS)
  GST_PLUGIN_STATIC_REGISTER(shm);
#endif
#if defined(GST_IOS_PLUGIN_ALPHA) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(alpha);
#endif
#if defined(GST_IOS_PLUGIN_ALPHACOLOR) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(alphacolor);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOFX) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(audiofx);
#endif
#if defined(GST_IOS_PLUGIN_CAIRO) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(cairo);
#endif
#if defined(GST_IOS_PLUGIN_CUTTER) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(cutter);
#endif
#if defined(GST_IOS_PLUGIN_DEBUG) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(debug);
#endif
#if defined(GST_IOS_PLUGIN_DEINTERLACE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(deinterlace);
#endif
#if defined(GST_IOS_PLUGIN_DTMF) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(dtmf);
#endif
#if defined(GST_IOS_PLUGIN_EFFECTV) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(effectv);
#endif
#if defined(GST_IOS_PLUGIN_EQUALIZER) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(equalizer);
#endif
#if defined(GST_IOS_PLUGIN_GDKPIXBUF) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(gdkpixbuf);
#endif
#if defined(GST_IOS_PLUGIN_IMAGEFREEZE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(imagefreeze);
#endif
#if defined(GST_IOS_PLUGIN_INTERLEAVE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(interleave);
#endif
#if defined(GST_IOS_PLUGIN_LEVEL) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(level);
#endif
#if defined(GST_IOS_PLUGIN_MULTIFILE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(multifile);
#endif
#if defined(GST_IOS_PLUGIN_REPLAYGAIN) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(replaygain);
#endif
#if defined(GST_IOS_PLUGIN_SHAPEWIPE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(shapewipe);
#endif
#if defined(GST_IOS_PLUGIN_SMPTE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(smpte);
#endif
#if defined(GST_IOS_PLUGIN_SPECTRUM) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(spectrum);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOBOX) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(videobox);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOCROP) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(videocrop);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOMIXER) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(videomixer);
#endif
#if defined(GST_IOS_PLUGIN_ACCURIP) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(accurip);
#endif
#if defined(GST_IOS_PLUGIN_AIFF) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(aiff);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOBUFFERSPLIT) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(audiobuffersplit);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOFXBAD) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(audiofxbad);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOLATENCY) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(audiolatency);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOMIXMATRIX) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(audiomixmatrix);
#endif
#if defined(GST_IOS_PLUGIN_AUTOCONVERT) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(autoconvert);
#endif
#if defined(GST_IOS_PLUGIN_BAYER) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(bayer);
#endif
#if defined(GST_IOS_PLUGIN_COLOREFFECTS) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(coloreffects);
#endif
#if defined(GST_IOS_PLUGIN_CLOSEDCAPTION) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(closedcaption);
#endif
#if defined(GST_IOS_PLUGIN_DEBUGUTILSBAD) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(debugutilsbad);
#endif
#if defined(GST_IOS_PLUGIN_FIELDANALYSIS) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(fieldanalysis);
#endif
#if defined(GST_IOS_PLUGIN_FREEVERB) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(freeverb);
#endif
#if defined(GST_IOS_PLUGIN_FREI0R) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(frei0r);
#endif
#if defined(GST_IOS_PLUGIN_GAUDIEFFECTS) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(gaudieffects);
#endif
#if defined(GST_IOS_PLUGIN_GEOMETRICTRANSFORM) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(geometrictransform);
#endif
#if defined(GST_IOS_PLUGIN_INTER) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(inter);
#endif
#if defined(GST_IOS_PLUGIN_INTERLACE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(interlace);
#endif
#if defined(GST_IOS_PLUGIN_IVTC) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(ivtc);
#endif
#if defined(GST_IOS_PLUGIN_LEGACYRAWPARSE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(legacyrawparse);
#endif
#if defined(GST_IOS_PLUGIN_PROXY) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(proxy);
#endif
#if defined(GST_IOS_PLUGIN_REMOVESILENCE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(removesilence);
#endif
#if defined(GST_IOS_PLUGIN_SEGMENTCLIP) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(segmentclip);
#endif
#if defined(GST_IOS_PLUGIN_SMOOTH) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(smooth);
#endif
#if defined(GST_IOS_PLUGIN_SPEED) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(speed);
#endif
#if defined(GST_IOS_PLUGIN_SOUNDTOUCH) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(soundtouch);
#endif
#if defined(GST_IOS_PLUGIN_TIMECODE) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(timecode);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOFILTERSBAD) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(videofiltersbad);
#endif
#if defined(GST_IOS_PLUGIN_VIDEOFRAME_AUDIOLEVEL) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(videoframe_audiolevel);
#endif
#if defined(GST_IOS_PLUGIN_WEBRTCDSP) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(webrtcdsp);
#endif
#if defined(GST_IOS_PLUGIN_LADSPA) || defined(GST_IOS_PLUGINS_EFFECTS)
  GST_PLUGIN_STATIC_REGISTER(ladspa);
#endif
#if defined(GST_IOS_PLUGIN_GOOM) || defined(GST_IOS_PLUGINS_VIS)
  GST_PLUGIN_STATIC_REGISTER(goom);
#endif
#if defined(GST_IOS_PLUGIN_GOOM2K1) || defined(GST_IOS_PLUGINS_VIS)
  GST_PLUGIN_STATIC_REGISTER(goom2k1);
#endif
#if defined(GST_IOS_PLUGIN_AUDIOVISUALIZERS) || defined(GST_IOS_PLUGINS_VIS)
  GST_PLUGIN_STATIC_REGISTER(audiovisualizers);
#endif
#if defined(GST_IOS_PLUGIN_CAMERABIN) || defined(GST_IOS_PLUGINS_CAPTURE)
  GST_PLUGIN_STATIC_REGISTER(camerabin);
#endif
#if defined(GST_IOS_PLUGIN_ASFMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(asfmux);
#endif
#if defined(GST_IOS_PLUGIN_DTSDEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(dtsdec);
#endif
#if defined(GST_IOS_PLUGIN_MPEGPSDEMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(mpegpsdemux);
#endif
#if defined(GST_IOS_PLUGIN_MPEGPSMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(mpegpsmux);
#endif
#if defined(GST_IOS_PLUGIN_MPEGTSDEMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(mpegtsdemux);
#endif
#if defined(GST_IOS_PLUGIN_MPEGTSMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(mpegtsmux);
#endif
#if defined(GST_IOS_PLUGIN_VOAACENC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(voaacenc);
#endif
#if defined(GST_IOS_PLUGIN_A52DEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(a52dec);
#endif
#if defined(GST_IOS_PLUGIN_AMRNB) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(amrnb);
#endif
#if defined(GST_IOS_PLUGIN_AMRWBDEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(amrwbdec);
#endif
#if defined(GST_IOS_PLUGIN_ASF) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(asf);
#endif
#if defined(GST_IOS_PLUGIN_DVDSUB) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(dvdsub);
#endif
#if defined(GST_IOS_PLUGIN_DVDLPCMDEC) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(dvdlpcmdec);
#endif
#if defined(GST_IOS_PLUGIN_XINGMUX) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(xingmux);
#endif
#if defined(GST_IOS_PLUGIN_REALMEDIA) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(realmedia);
#endif
#if defined(GST_IOS_PLUGIN_X264) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(x264);
#endif
#if defined(GST_IOS_PLUGIN_LIBAV) || defined(GST_IOS_PLUGINS_CODECS_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(libav);
#endif
#if defined(GST_IOS_PLUGIN_RTMP) || defined(GST_IOS_PLUGINS_NET_RESTRICTED)
  GST_PLUGIN_STATIC_REGISTER(rtmp);
#endif
#if defined(GST_IOS_PLUGIN_VULKAN) || defined(GST_IOS_PLUGINS_VULKAN)
  GST_PLUGIN_STATIC_REGISTER(vulkan);
#endif
#if defined(GST_IOS_PLUGIN_NLE) || defined(GST_IOS_PLUGINS_GES)
  GST_PLUGIN_STATIC_REGISTER(nle);
#endif
#if defined(GST_IOS_PLUGIN_GES) || defined(GST_IOS_PLUGINS_GES)
  GST_PLUGIN_STATIC_REGISTER(ges);
#endif
  
  /* Lower the ranks of filesrc and giosrc so iosavassetsrc is
   * tried first in gst_element_make_from_uri() for file:// */
  reg = gst_registry_get();
  plugin = gst_registry_lookup_feature(reg, "filesrc");
  if (plugin)
    gst_plugin_feature_set_rank(plugin, GST_RANK_SECONDARY);
  plugin = gst_registry_lookup_feature(reg, "giosrc");
  if (plugin)
    gst_plugin_feature_set_rank(plugin, GST_RANK_SECONDARY-1);
}

#pragma clang diagnostic pop
