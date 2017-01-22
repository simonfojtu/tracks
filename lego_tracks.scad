// LEGO DUPLO brick unit size
function LEGO_get_unit_length() = 31.66; // 2x2 nibbles
function LEGO_get_unit_height() = 9.6;
// thickness of the track, on which the wheels ride
function LEGO_get_track_thickness() = 6;
function LEGO_get_wall_height() = LEGO_get_track_thickness();//6.4;
function LEGO_get_track_length() = 4 * LEGO_get_unit_length();

// length [mm]
module LEGO_TrackProfile(length) {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    // wall
    wall_bottom_width = 31.5;
    wall_top_width = 31.5;//29.2;
    wall_height = LEGO_get_wall_height();
    cube([length, width, thickness]);
    // wall
    translate([0,width/4,thickness])
    rotate([90,0,90])
    linear_extrude(height=length)
    polygon(points=[
        [0,0],
        [wall_bottom_width, 0],
        [wall_bottom_width-(wall_bottom_width-wall_top_width)/2, wall_height],
        [(wall_bottom_width-wall_top_width)/2, wall_height]
    ]);
}

module LEGO_TrackProfile2() {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    // wall
    wall_bottom_width = 31.5;
    wall_top_width = 29.2;
    wall_height = LEGO_get_wall_height();
    
    wb = (width - wall_bottom_width)/2;
    wt = (width - wall_top_width)/2;
    
    module Half() { 
        polygon(points=[
            [0, 0],
            [width/2, 0],
            [width/2, thickness],
            [width/2-wb, thickness],
            [width/2-wt, thickness + wall_height],
            [0, thickness + wall_height]
        ]);
    }
    
    Half();
    rotate([0,180,0]) Half();
}

// length [mm]
module LEGO_TrackProfile3(length) {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    // wall
    wall_bottom_width = 31.5;
    wall_top_width = 31.5;//29.2;
    wall_height = LEGO_get_wall_height();
    
    module pos() {
        cube([length, width, thickness+wall_height]);
        // TODO pin
    }
    
    module neg() {
        union() {
        translate([0, 0, thickness]) cube([length, (width-wall_bottom_width)/2, wall_height]);
        translate([0, width-(width-wall_bottom_width)/2, thickness]) cube([length, (width-wall_bottom_width)/2, wall_height]);
        }
    }

    difference() {
        pos();
        neg();
    }
}

module LEGO_TrackProfile_negative(length) {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    // wall
    wall_bottom_width = 31.5;
    wall_top_width = 31.5;//29.2;
    wall_height = LEGO_get_wall_height();
    
    union() {
    translate([0, 0, thickness]) cube([length, (width-wall_bottom_width)/2, wall_height]);
    translate([0, width-(width-wall_bottom_width)/2, thickness]) cube([length, (width-wall_bottom_width)/2, wall_height]);
    }
}

module LEGO_TrackBottom(length) {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
   
    cx = -length/2;
    cy = -width/2;
    translate([cx,cy,0]) cube([length, width, thickness]);
}

module LEGO_TrackTop(length) {
    width = 2 * LEGO_get_unit_length();
    thickness = LEGO_get_track_thickness();
    // wall
    wall_bottom_width = 31.5;
    wall_top_width = 31.5;//29.2;
    wall_height = LEGO_get_wall_height(); 
    // wall
    cx = -length/2;
    cy = -width/2;
    translate([cx,cy,0]) {
        translate([0,width/4,thickness])
        rotate([90,0,90])
        linear_extrude(height=length)
        polygon(points=[
            [0,0],
            [wall_bottom_width, 0],
            [wall_bottom_width-(wall_bottom_width-wall_top_width)/2, wall_height],
            [(wall_bottom_width-wall_top_width)/2, wall_height]
        ]);
    }
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
    curve_radius = 450/2;
    one = (left ? 1 : -1);
    angle = 30 * one;
    rz = - 90 * one;
    
    
    difference() {
        union() {
            rotate([0, 0, rz]) translate([-curve_radius,0,0])
                rotate_extrude(angle=angle, $fn=200) translate([curve_radius,0,0]) LEGO_TrackProfile2(1);
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
    cx = -length/2 * (center?1:0);
    cy = -LEGO_get_unit_length() * (center?1:0);
    
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
                    translate([cx,cy,0]) 
                    LEGO_TrackProfile_negative(length);
                }
            }
        }
    }
    
    LEGO_TrackCrossings_(angle, unit_length, center);
}


module LEGO_Turntable(angle = 60, N = 3, unit_length = 2) {
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
    rotate([0,0,10])
    intersection() {
        LEGO_TrackTop(length_, center=true);
        cylinder(r=length_/2,h=10*LEGO_get_wall_height(),center=true,$fn = 80);
    }
    translate([0, 0, LEGO_get_track_thickness()/2])
            cylinder(r=length_/2,h=LEGO_get_track_thickness(),center=true,$fn = 80);
}

module ZOO() {
    // ZOO of implemented modules with different arguments
    // straight track
    LEGO_Track(1);
    // decorated straight track
    translate([0,  100, 0]) LEGO_Track(1, decorated=true);
    // long ones
    translate([0, -100, 0]) LEGO_Track(2);
    translate([0, -200, 0]) LEGO_Track(3);
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

ZOO();
