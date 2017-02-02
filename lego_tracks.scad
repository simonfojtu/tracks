// LEGO DUPLO brick unit size
function LEGO_get_unit_length() = 31.66; // 2x2 nibbles
function LEGO_get_unit_height() = 9.6;
// thickness of the track, on which the wheels ride
function LEGO_get_track_thickness() = 6;
function LEGO_get_wall_height() = LEGO_get_track_thickness();//6.4;
function LEGO_get_wall_bottom_width() = 31.5;
function LEGO_get_track_length() = 4 * LEGO_get_unit_length();
function LEGO_get_curve_radius() = 286.5 - LEGO_get_unit_length(); // from center of tracks

module LEGO_TrackTopProfileNegative(full=false) {
    width = (full ? 2 * LEGO_get_unit_length() : 54);
    thickness = LEGO_get_wall_height();
    translate([0.01,0,0]) // hack because the difference between full rectangle and top is slightly thinner than it should be.
    difference() {
        translate([LEGO_get_track_thickness()+thickness/2, 0, 0]) square(size = [thickness, width], center = true);
        LEGO_TrackTopProfile();
    }
}

module LEGO_TrackProfile_negative(length) {
    translate([-length/2, 0, 0])
    rotate([0,-90,180])
    linear_extrude(height=length)
    LEGO_TrackTopProfileNegative();
}

module LEGO_TrackBottomProfile() {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    translate([thickness/2, 0, 0]) square(size = [thickness, width], center = true);
}

module LEGO_TrackBottom(length) {
    translate([-length/2, 0, 0])
    rotate([0,-90,180])
    linear_extrude(height=length)
    LEGO_TrackBottomProfile();
}

module LEGO_TrackTopProfile() {
    thickness = LEGO_get_wall_height();
    width = LEGO_get_wall_bottom_width();
    
    translate([LEGO_get_track_thickness()+thickness/2, 0, 0]) square(size = [thickness, width], center = true);
}

module LEGO_TrackTop(length) {
    translate([-length/2, 0, 0])
    rotate([0,-90,180])
    linear_extrude(height=length)
    LEGO_TrackTopProfile();
}


module LEGO_TrackConnector_Hole() {
    r = 9.3/2;
    hole_width = 7;
    doffset = 8; // distance from middle to the hole
    
    thickness = LEGO_get_track_thickness();
    
    hull() {
        translate([6, doffset, 1+(thickness-1)/2]) 
            cylinder(r=r,h=10*thickness,center=true,$fs = 0.01);
        translate([6+2, doffset, 1+(thickness-1)/2]) 
            cylinder(r=r,h=10*thickness,center=true,$fs = 0.01);
    }
    
    translate([0, doffset, 1+(thickness-1)/2]) cube([10, hole_width, 10*thickness], true);
}

module LEGO_TrackConnector_Pin() {
    pin_dia = 9.0;
    pin_width = 6.3;
    pin_length = 10;
    doffset = 8; // distance from middle to the pin
    
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    
    pin_height=thickness + LEGO_get_wall_height();
    pin_offset=pin_height / 2;
    translate([-8, -doffset, pin_offset]) 
        cylinder(r=pin_dia/2,h=pin_height,center=true,$fs = 0.01);
    translate([0, -doffset, pin_offset])
        cube([pin_length, pin_width, pin_height], center=true);
}

module LEGO_Track_decoration_neg(unit_length) {
    w=7;
    width = 2 * LEGO_get_unit_length();
    module SleeperSpace() {
        cube([LEGO_get_unit_length(),w,LEGO_get_track_thickness()], center=true);
    }
    
    for (n=[1:2:unit_length+2]) {
        for (s=[-1,1]) {
            translate([n*s*LEGO_get_unit_length(),(width-w)/2,LEGO_get_track_thickness()/2]) SleeperSpace();
            translate([n*s*LEGO_get_unit_length(),-(width-w)/2,LEGO_get_track_thickness()/2]) SleeperSpace();
        }
    }      
}

// length [unit]
// classic track has a length of 1 (8 nibbles)
module LEGO_Track(unit_length, center=true, decorated=false) {
    if (unit_length <= 0) {
        echo("LEGO_Track: unit_length must be greater than 0");
    }

    length = unit_length * LEGO_get_track_length();
    
    // translate to center
    cx = -length/2 * (center?1:0);
    cy = -LEGO_get_unit_length() * (center?1:0);
    
    difference() {
        union() {
            LEGO_TrackBottom(length);
            LEGO_TrackTop(length);
            translate([-length/2, -0, 0]) LEGO_TrackConnector_Pin();
            translate([length/2, -0, 0]) rotate([0, 0, 180]) LEGO_TrackConnector_Pin();
        }
        union() {
            translate([-length/2, -0, 0]) LEGO_TrackConnector_Hole();
            translate([length/2, -0, 0]) rotate([0, 0, 180]) LEGO_TrackConnector_Hole();
            if (decorated && unit_length >= 1)
                LEGO_Track_decoration_neg(unit_length);
        }
    }
}

module LEGO_Curve(left=true) {
    curve_radius = LEGO_get_curve_radius();
    one = (left ? 1 : -1);
    angle = 30 * one;
    rz = - 90 * one;
    
    
    difference() {
        union() {
            rotate([0, 0, rz]) translate([-curve_radius,0,0])
                rotate_extrude(angle=angle, $fn=200) translate([curve_radius,0,0]) 
            {
                rotate([0,0,90]) {
                    LEGO_TrackTopProfile();
                    LEGO_TrackBottomProfile();
                }
            }
            LEGO_TrackConnector_Pin();
            translate([0, one * curve_radius, 0]) rotate([0,0,angle]) translate([0, -one * curve_radius, 0]) rotate([0, 0, 180]) LEGO_TrackConnector_Pin();
        }
        union() {
            LEGO_TrackConnector_Hole();
            translate([0, one * curve_radius, 0]) rotate([0,0,angle]) translate([0, -one * curve_radius, 0]) rotate([0, 0, 180]) LEGO_TrackConnector_Hole();
        }
    }
}

// Buffer stop
module LEGO_BufferStop() {
    unit_length = 1;
    N = 6;

    width = 2 * LEGO_get_unit_length();
    length = unit_length * LEGO_get_track_length();
    height = LEGO_get_track_thickness();
    
    // translate to center
    cx = -length/2;
    cy = -LEGO_get_unit_length();
    
    difference() {
        union() {
            LEGO_TrackBottom(length);
            LEGO_TrackTop(length);
            translate([-length/2, -0, 0]) LEGO_TrackConnector_Pin();
        }
        union() {
            translate([-length/2, -0, 0]) LEGO_TrackConnector_Hole();
        }
    }
    for (i=[1:N]) {
        length_ = cos(10*(i-1)) * LEGO_get_track_length() - LEGO_get_track_length()/2;
        translate([length_/2, 0, (i-0.5)*height])
        cube([length_, width, height],
            center=true);
    }
}

module LEGO_TrackCrossings(        
        angle = 60, // angle between neigbouring tracks
        N = 2, // number of straight tracks
        unit_length = 1, // 1 = normal track length
        center=true) { // center at [0,0]

    module LEGO_TrackCrossings_(
            angle,
            unit_length = 1,
            center=true) {
        length = unit_length * LEGO_get_track_length();
        cx = -length/2 * (center?1:0);
        cy = -LEGO_get_unit_length() * (center?1:0);
        
        difference() {
            union() {
                for ( i = [0 : N-1] ){
                    rotate([0,0, i * angle])
                    LEGO_Track(unit_length);
                }
            }
            union() {
                for ( i = [0 : N-1] ){
                    rotate([0,0, i * angle])
                    LEGO_TrackProfile_negative(length);
                }
            }
        }
    }
    
    LEGO_TrackCrossings_(angle, unit_length, center);
}


module LEGO_Turntable(angle = 60, N = 3, unit_length = 2) {
    inner_track_angle = 0;
    if (unit_length <= 1) {
        echo("LEGO_Turntable: unit_length must be greater than 1");
    }
    // todo fix the teeth at unit_length = 2 and N=7
    length = 0.8 * unit_length * LEGO_get_track_length();
    
    difference() {
        union() {
            LEGO_TrackCrossings(angle=angle, N=N, unit_length=unit_length, center=true, assembled=true);
            translate([0,0, LEGO_get_track_thickness()/2]) cylinder(r=length/2*1.1, h=LEGO_get_track_thickness(),center=true,$fn=80);
        }
        translate([0, 0, (LEGO_get_wall_height() + LEGO_get_track_thickness())/2])
        cylinder(r=length/2,h=LEGO_get_track_thickness() + LEGO_get_wall_height(),center=true,$fn = 80);
    }
        
    // inner track
    length_ = length-4;
    cx = -length/2;
    cy = -LEGO_get_unit_length();
    rotate([0,0,inner_track_angle])
    intersection() {
        LEGO_TrackTop(length_, center=true);
        cylinder(r=length_/2,h=10*LEGO_get_wall_height(),center=true,$fn = 80);
    }
    // base plate
    translate([0, 0, LEGO_get_track_thickness()/2])
        cylinder(r=length_/2,h=LEGO_get_track_thickness(),center=true,$fn = 80);
    // rim
    difference() {
    translate([0, 0, LEGO_get_track_thickness()+LEGO_get_wall_height()/2])
        difference() {
            cylinder(r=length_/2,  h=LEGO_get_wall_height(),center=true,$fn = 80);
            cylinder(r=length_/2-6,h=LEGO_get_wall_height(),center=true,$fn = 80);
        }
        rotate([0,0, inner_track_angle])
        LEGO_TrackProfile_negative(length);
    }
}

module LEGO_Switch() {
    curve_radius = LEGO_get_curve_radius();
    // blade rotation axis position
    tx=-90;
    ty=-22;
    // blade tip thickness as a function of the az angle
    az=5;
    // rotate extrude profile at curve radius
    module curve(one=1) {
        angle = 30 * one;
        rz = - 90 * one;
        rotate([0, 0, rz])
        translate([-curve_radius,0,0])
        rotate_extrude(angle=angle, $fn=200)
        translate([curve_radius,0,0]) 
        rotate([0,0,90])
        children(0);
    }
    // base plate
    module bottom(one=1) {
        curve(one)
        LEGO_TrackBottomProfile();
        translate([10,0,0]) cube([30,50,2*LEGO_get_track_thickness()], center=false);
    }
    // top middle section
    module top(one=1) {
        curve(one)
        LEGO_TrackTopProfile();
    }
    // top negative of middle section
    module top_negative(one=1) {
        curve(one)
        LEGO_TrackTopProfileNegative(full=false);
    }
    
    module blade(angle=0, dilate=2) {

        translate([0,0,LEGO_get_track_thickness()])
        linear_extrude(height = LEGO_get_track_thickness())
        offset(r = dilate)
        projection(cut=true)
        translate([-tx,-ty,-1.1*LEGO_get_track_thickness()]) {
            rotate([0,0,angle])
            difference() {
                union() {
                    dx=70; // length of blade from axis to tip
                    translate([-dx/2,0,1.5*LEGO_get_track_thickness()]) cube([dx, 22, LEGO_get_track_thickness()], center=true);
                    translate([0,0.6,LEGO_get_track_thickness()])
        cylinder(r=11, h=LEGO_get_track_thickness());
                }
                union() {
                    rotate([0,0,-az]) translate([tx,ty,0]) curve(1)        LEGO_TrackTopProfileNegative(full=false);
                    rotate([0,0,az]) translate([tx,ty,0]) curve(-1) LEGO_TrackTopProfileNegative(full=false);
                }
            }
        }
    }
    
    difference() {
        union() {
            difference() {
                union() {
                    for (one=[-1,1]) {
                        top(one);
                        bottom(one);
                    }
                }
                union() {
                    for (one=[-1,1]) {
                        top_negative(one);
                    }
                    LEGO_TrackConnector_Hole();
                    for (one=[-1,1]) {
                        angle = 30 * one;
                        translate([0, one * curve_radius, 0]) rotate([0,0,angle]) translate([0, -one * curve_radius, 0]) rotate([0, 0, 180]) LEGO_TrackConnector_Hole();
                    }
                }
            }
            // connector pins
            LEGO_TrackConnector_Pin();
            for (one=[-1,1]) {
                angle = 30 * one;
                translate([0, one * curve_radius, 0]) rotate([0,0,angle]) translate([0, -one * curve_radius, 0]) rotate([0, 0, 180]) LEGO_TrackConnector_Pin();
            }
        }
        union() {
            for (a=[-az-1:az+1])
            blade(a);
            translate([-tx,-ty,LEGO_get_track_thickness()/2]) cylinder(r=2, h=LEGO_get_track_thickness(), center=true,$fs = 0.01);
        }
    }
    difference() {
        blade(angle=0, dilate=1); // limit angle: angle = +-(az+2)
        translate([-tx,-ty,1.5*LEGO_get_track_thickness()]) cylinder(r=2, h=LEGO_get_track_thickness(), center=true,$fs = 0.01);
    }
}

module ZOO() {
    // ZOO of implemented modules with different arguments
    // straight track
    LEGO_Track(1);
    // decorated straight track
    translate([0,  100, 0]) LEGO_Track(1, decorated=true);
    // long ones
    translate([0, -100, 0]) LEGO_Track(2, decorated=true);
    translate([0, -200, 0]) LEGO_Track(3, decorated=true);
    // short one
    translate([0,  200, 0]) LEGO_Track(0.5);
    // buffer stop
    translate([0,  300, 0]) LEGO_BufferStop();
    // curve
    translate([-60, 400, 0]) LEGO_Curve(left=true);


    // 2 way 60deg crossing of normal length
    translate([200, 0, 0]) LEGO_TrackCrossings(angle=60, N=2, unit_length=1, center=true, assembled=true);
    
    // 2 way 90deg crossing of normal length
    translate([200, 200, 0]) LEGO_TrackCrossings(angle=90, N=2, unit_length=1, center=true, assembled=true);
    
    // 3 way 60deg crossing of normal length
    translate([200, 400, 0]) LEGO_TrackCrossings(angle=60, N=3, unit_length=1, center=true, assembled=true);
    

    // turntable 3-way
    translate([500, 0, 0]) LEGO_Turntable(angle = 60, N = 3);
    
    // turntable 7-way
    translate([500, 300, 0]) LEGO_Turntable(angle = 30, N = 7);
    
    // switch
    translate([800, 0, 0]) LEGO_Switch();
    
}

module cut2(dx=0, dy=0) {
        translate([dx, dy, 0])
        projection(cut=true)
        translate([0,0,-0.5*LEGO_get_track_thickness()])
            children(0);
        
        projection(cut=true)
        translate([0,0,-1.5*LEGO_get_track_thickness()])
            children(0);
}


module fillet(r) {
   offset(r = -r) {
     offset(delta = r) {
       children();
     }
   }
}

//ZOO();
