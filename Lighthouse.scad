// circuits carrier dimensions
cledh=10; // carrier height reserved for led
cesph=65; // carrier height reserved for esp
cvwh=15; // carrier height reserver for vent windows
cespw=40; // carrier width reserved for esp
ch=cledh+cesph+cvwh; // carrier height
cw=cespw; // carrier width
clh=ch-cledh; // carrier led area start height
cth=2; // wall thickens carrier

// lighthouse proportions
prbah=0.05; // base height
prf0h=0.30; // ground floor height
prf1h=0.30; // first floor height
prf2h=0.35; // second floor ( light and roof ) height
anr=45; // roof angle
prbw=1.1; // balcony diameter
prlw=0.7; // light diameter
prbrh=0.05; // balcony railing height
prbth=0.05; // balcony transition height

// technical
clr=0.1; // clearance between objects
th=1.6; // wall thickness

//lighthouse
di=cw+clr; // lighthouse inner diameter
ri=di/2; // lighthouse inner radius
ro=ri+th; // lighthouse outer radius
rol=ro*prlw; // light outer radius
rh=tan(anr)*rol; // roof height
ta=clh/(prbah+prf0h+prf1h)+rh; // lighthouse height
rob=ro*prbw; // balcony outer radius
rib=rob-th; // balcony inner radius
ril=rol-th; // light inner radius
tab=ch+th; // balcony height
tabr=tab+ta*prbrh; // balcony railing height
tar=ta-rh; // roof floor height
thr=th/sin(90-anr); // roof thickness

clw=(ril-clr)*2; // carrier led area narrow width

// base
rbi=ro+clr; // base inner radius
bta=ta*prbah; // base height
rbo=rbi+ro*0.15; // base outer radius

// cable channel
cabd=3.5; // cable diameter for cable channel

// light
lwic=12; // light windows number
lwico=0.7; // coefficient light window width to windows distance
lwiw=sin(360/lwic/2)*rol*2*lwico; // light windows width
lwih=(tar-tabr)*0.8; // light windows height

//floors
floh=ta*0.25; // floor height
h0h=bta; // ground floor height
h1h=h0h+floh; // first floor height
h2h=h1h+floh; // second floor height
hwiw=ro/4; // house windows width
hwih=floh/2; // house windows height
hwifh=(floh-hwih)/2; // house windows height over floor
lrih=lwih; // light reflector height
lrita=tabr+lwih/2-lrih/2; // light reflector position

lr=th*2; // lock radius

odist=rbo*2+20; // object distance

module carrierOutline() {
    polygon(points=[
        [0,0],[cw/2,0],[cw/2,clh],[clw/2,ch],[0,ch]
    ]);
}

module lockOutline(){
    difference(){
        circle(lr, $fn=200);
        translate([0,-lr,0]) square([lr, lr*2]);
    };
}

module bodyOutline() {
    union() {
        polygon(points=[
            [ri,0],[ro,0],
            [ro,tab-ta*0.06],
            [rob,tab],[rob,tabr],[rib,tabr], 
            [rib,tab],[rol,tab],
            [rol,tar],[0,ta],
            [0,tar-th],[ril, tar-th],
            [ril,tab-th],[ri, clh]
        ]);
        translate([ro, hwifh+hwih/2, 0]) lockOutline();
    }
    
}

module lightReflectorOutline() {
    polygon(points=[
        [0,tar],[0,lrita],[ril,tar]
    ]);
}   

module carrier() {
    difference() {
        translate([0,thr/2,0])
        rotate([90,0,0])
        union(){
            linear_extrude(thr)
                union() {
                    carrierOutline();
                    mirror([1,0,0])
                        carrierOutline();
                };
            carrierFoot();
        };
        translate([cw/5,thr*1.5,0]) window(thr*3,cw/4,cvwh);
        translate([-cw/5,thr*1.5,0]) window(thr*3,cw/4,cvwh);
        // clearance for the edges
        translate([clr,0,0]) bodyComplete(); 
        translate([-clr,0,0]) bodyComplete();     
    }
}

module carrierFoot() {
    translate([-cw/2,0,thr/2])
    rotate([0,90,0])
    linear_extrude(cw)
    polygon(points=[
        [-thr*1.5,0],[thr*1.5,0],[thr/2,cvwh],[-thr/2,cvwh]
    ]);
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
     [0,0],[rbi,0],[rbi,bta],[rbi+th,bta],[rbo,-th-cabd],[0,-th-cabd]
    ]);
}

module base() {
    rotate_extrude($fn=200)
        baseOutline();
}

module cableChannel() {
    translate([0,thr*1.5,bta])
    mirror([0,1,0])
    mirror([0,0,1])
    window(rbo,3.5,bta+cabd);
}

module baseComplete() {
    color("gray")
    union() {
        difference() {
            base();
            cableChannel();
        };            
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
    translate([odist,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,h1h]) cube([rob*2,rob*2,ta]);
    };
}

module firstFloorSeparate() {
    color("red") translate([odist*2,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,h1h]);
        translate([-rob,-rob,h2h]) 
            cube([rob*2,rob*2,ta]);
    };
}

module secondFloorSeparate() {
    translate([odist*3,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,h2h]);
        translate([-rob,-rob,tar]) cube([rob*2,rob*2,ta]);
    };
}

module roofSeparate() {
    color("red") translate([odist*4,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,tar]);
    };
}

module completeAssembly(){
    baseComplete();
    bodyComplete();
}

module projectionX() {
    projection(cut=true)
    rotate([-90,0,0])
    completeAssembly();
}

module projectionY() {
    projection(cut=true)
    rotate([0,-90,0])
    completeAssembly();
}

//lockOutline();
//bodyOutline();
//lightReflectorOutline();
//baseOutline();
//carrierOutline();
//carrierFoot();
//windowOutline(5,10);
//carrier();
//bodyOnly();
//cableChannel();
//base();
//window(15,5,10);
//lwindows();
//h0windows();

//projectionX();
//projectionY();

translate([-odist*2,0,0]) 
    baseComplete();
translate([-odist,0,0]) 
    bodyComplete();
completeAssembly();
groundFloorSeparate();
firstFloorSeparate();
secondFloorSeparate();
roofSeparate();
