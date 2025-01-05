ta=100; // lighhouse height
di=30; // lighhouse inner diameter
th=1.6; // wall thickness
anr=45; // lighthouse roof angle
ri=di/2; // lighthouse inner radius
ro=ri+th; // lighthouse outer radius
rob=ro*1.1; // balkony outher radius
rib=rob-th; // balknoy inner radius
rol=ro*0.8; // light outer radius
ril=rol-th; // ligth inner radius
tab=ta*0.65; // balkony height
tabr=tab+ta*0.05; // balkony railing height
tar=ta-tan(anr)*rol; // roof height
thr=th/sin(90-anr); // roof thickness
rbi=ro+0.25; // base inner radius
bta=ta*0.05; // base height
rbo=rbi+ro*0.15; // base outer radius
lwic=12; // light windows number
lwico=0.7; // coefficient light window width to windows distance
lwiw=sin(360/lwic/2)*rol*2*lwico; // light windows width
lwih=(tar-tabr)*0.8; // light windows height
hwiw=ro/5; // house windows width
hwih=ta/10; // house windows height
h0h=bta; // ground floor height
h0wic=8; // ground floor windows number
h1h=ta*0.34; // first floor height
h1wic=4; // first floor windows number



module bodyOutline() {
    polygon(points=[
        [ri,0],[ro,0],[ro,tab-ta*0.06],[rob,tab],[rob,tabr],[rib,tabr], [rib,tab],[rol,tab],[rol,tar],[0,ta],
    [0,ta-thr],[ril, tar-thr+th/tan(90-anr)],[ril,tab-th],[ri, tab-(ri-ril)*2]
    ]);
}
 
module bodyOnly() {
    rotate_extrude($fn=200)
        bodyOutline();
}

module baseOutline() {
    polygon(points=[
     [0,0],[rbi,0],[rbi,bta],[rbi+th,bta],[rbo,-th],[0,-th]
    ]);
}

module base() {
    color("black")
    rotate_extrude($fn=200)
        baseOutline();
}

module window(r,w,h) {
    translate([0,0,h/2])
    rotate([0,-90,0])
    translate([-h/2,-w/2,-r])
    linear_extrude(height=r*2)
    union() {
        square([h-w/2,w]);
        translate([h-w/2,w/2]) circle(w/2, $fn=200);
    }
}

module lwindows() {
    for(ang = [0:360/lwic:180]) {
        rotate([0,0,ang]) window(rol,lwiw,lwih);
    }
}

module h0windows() {
    for(ang = [0:360/h0wic:180]) {
        rotate([0,0,ang]) window(ro,hwiw,hwih);
    }
}

module h1windows() {
    for(ang = [0:360/h1wic:180]) {
        rotate([0,0,ang]) window(ro,hwiw,hwih);
    }
}

module bodyComplete() {
    color("white")
    difference() {
        bodyOnly();
        translate([0,0,tabr]) lwindows();
        translate([0,0,h0h]) h0windows();
        translate([0,0,h1h]) h1windows();
    }
}

//bodyOutline();
//baseOutline();
//bodyOnly();
base();
//window(15,5,10);
//lwindows();
//h0windows();
bodyComplete();
