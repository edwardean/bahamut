//
//  SDColors.h
//  Bahamut
//
//  Created by Steven on 8/23/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef Bahamut_SDColors_h
#define Bahamut_SDColors_h



#define SDBlueHue (210.0)

#define SDVeryDarkBlue [NSColor colorWithCalibratedHue:SDBlueHue/360.0 saturation:0.97 brightness:0.52 alpha:1.0]
#define SDDarkBlue [NSColor colorWithCalibratedHue:SDBlueHue/360.0 saturation:0.67 brightness:0.92 alpha:1.0]
#define SDMediumBlue [NSColor colorWithCalibratedHue:SDBlueHue/360.0 saturation:0.47 brightness:0.92 alpha:1.0]
#define SDLightBlue [NSColor colorWithCalibratedHue:SDBlueHue/360.0 saturation:0.36 brightness:0.92 alpha:1.0]



#define SDVolumeSliderBackColor [NSColor colorWithCalibratedWhite:1.00 alpha:1.0]
#define SDVolumeSliderForeColor SDLightBlue


#define SDTrackBackgroundColor [NSColor colorWithCalibratedWhite:1.0 alpha:1.0]



#define SDTableRowSelectionColor [NSColor colorWithCalibratedHue:206.0/360.0 saturation:0.26 brightness:0.97 alpha:1.0]
#define SDTableRowSelectionUnfocusedColor [NSColor colorWithCalibratedHue:206.0/360.0 saturation:0.08 brightness:0.99 alpha:1.0]




#define SDButtonBackgroundColor [NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
#define SDButtonBackgroundColorPressed [NSColor colorWithCalibratedWhite:0.97 alpha:1.0]
#define SDButtonNormalColor SDDarkBlue
#define SDButtonHighlightColor SDMediumBlue
#define SDButtonDisabledColor SDLightBlue


#endif
