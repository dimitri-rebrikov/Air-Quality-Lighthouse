ta=100; // lighthouse height
di=30; // lighthouse inner diameter
th=1.6; // wall thickness
thcr=2; // wall thickens carrier
anr=45; // lighthouse roof angle
ri=di/2; // lighthouse inner radius
ro=ri+th; // lighthouse outer radius
rob=ro*1.1; // balcony outer radius
rib=rob-th; // balcony inner radius
rol=ro*0.7; // light outer radius
ril=rol-th; // light inner radius
tab=ta*0.65; // balcony height
tabr=tab+ta*0.05; // balcony railing height
tar=ta-tan(anr)*rol; // roof height
thr=th/sin(90-anr); // roof thickness
rbi=ro+0.25; // base inner radius
bta=ta*0.05; // base height
rbo=rbi+ro*0.15; // base outer radius
lwic=12; // light windows number
lwico=0.7; // coefficient light window width to windows distance
lwiw=sin(360/lwic/2)*rol*2*lwico; // light windows width
lwih=(tar-tabr)*0.8; // light windows height
floh=ta*0.25; // floor height
h0h=bta; // ground floor height
h1h=h0h+floh; // first floor height
h2h=h1h+floh; // second floor height
hwiw=ro/4; // house windows width
hwih=floh/2; // house windows height
hwifh=(floh-hwih)/2; // house windows height over floor
lrih=lwih; // light reflector height
lrita=tabr+lwih/2-lrih/2; // light reflector position

module bodyOutline() {
    polygon(points=[
        [ri,0],[ro,0],[ro,tab-ta*0.06],[rob,tab],[rob,tabr],[rib,tabr], [rib,tab],[rol,tab],[rol,tar],[0,ta],
    [0,tar-th],[ril, tar-th],[ril,tab-th],[ri, tab-(ri-ril)*2]
    ]);
}

module lightReflectorOutline() {
    polygon(points=[
        [0,tar],[0,lrita],[ril,tar]
    ]);
}   
    
module carrierOutline() {
    difference() { 
        polygon(points=[
            [0,0],[ri,0],[ri,tab-(ri-ril)*2],[ril,tab-th],[0,tab-th]
        ]);
        translate([ri*2/5/2,0,0]) windowOutline(ri*2/5,lwih);
    }
}

module carrier() {
    difference() {
        translate([0,thr/2,0])
        rotate([90,0,0])
        linear_extrude(thr)
            union() {
                carrierOutline();
                mirror([1,0,0])
                    carrierOutline();
            };
        bodyComplete();
    }
}    
 
module bodyOnly() {
    rotate_extrude($fn=200)
        bodyOutline();
}

module lightReflector() {
    rotate_extrude($fn=200)
        lightReflectorOutline();
}

module baseOutline() {
    polygon(points=[
     [0,0],[rbi,0],[rbi,bta],[rbi+th,bta],[rbo,-th],[0,-th]
    ]);
}

module base() {
    rotate_extrude($fn=200)
        baseOutline();
}

module baseComplete() {
    color("grey")
    union() {
        base();
        carrier();
    }
}

module windowOutline(w,h) {
    union() {
        square([w,h-w/2]);
        translate([w/2,h-w/2]) circle(w/2, $fn=200);
    };
}  

module window(r,w,h) {
    translate([0,-r,h/2])
    rotate([90,0,0])
    translate([-w/2,-h/2,-r])
    linear_extrude(height=r)
    windowOutline(w,h);
}

module lwindows() {
    for(ang = [0:360/lwic:360]) {
        rotate([0,0,ang]) window(rol,lwiw,lwih);
    }
}

module h0windows() {
    window(ro,hwiw,hwih);
}

module h1windows() {
    window(ro,hwiw,hwih);
}

module bodyComplete() {
    color("white")
    union() {
        difference() {
            bodyOnly();
            translate([0,0,tabr]) lwindows();
            translate([0,0,h0h+hwifh]) h0windows();
            translate([0,0,h1h+hwifh]) h1windows();
        };
        lightReflector();
    }
}

module groundFloorSeparate() {
    translate([50,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,h1h]) cube([rob*2,rob*2,ta]);
    };
}

module firstFloorSeparate() {
    color("red") translate([100,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,h1h]);
        translate([-rob,-rob,h2h]) 
            cube([rob*2,rob*2,ta]);
    };
}

module secondFloorSeparate() {
    translate([150,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,h2h]);
        translate([-rob,-rob,tar]) cube([rob*2,rob*2,ta]);
    };
}

module roofSeparate() {
    color("red") translate([200,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,tar]);
    };
}


//bodyOutline();
//lightReflectorOutline();
//baseOutline();
//carrierOutline();
//windowOutline(5,10);
//carrier();
//bodyOnly();
//base();
//window(15,5,10);
//lwindows();
//h0windows();


translate([-50,0,0]) baseComplete();
bodyComplete();

groundFloorSeparate();
firstFloorSeparate();
secondFloorSeparate();
roofSeparate();
