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
wic=12; // windows count
wico=0.7; // coefficient window width to windows distance
wiw=sin(360/wic/2)*rol*2*wico; // windows width
wih=(tar-tabr)*0.8; // windows height


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
    rotate_extrude($fn=200)
        baseOutline();
}

module window() {
    translate([0,0,wih/2])
    rotate([0,-90,0])
    translate([-wih/2,-wiw/2,-rol])
    linear_extrude(height=rol*2)
    union() {
        square([wih-wiw/2,wiw]);
        translate([wih-wiw/2,wiw/2]) circle(wiw/2, $fn=200);
    }
}

module windows() {
    for(ang = [0:360/wic:180]) {
        rotate([0,0,ang]) window();
    }
}

module bodyComplete() {
    difference() {
        bodyOnly();
        translate([0,0,tabr]) windows();
    }
}

//bodyOutline();
//baseOutline();
//bodyOnly();
base();
//window();
//windows();
bodyComplete();