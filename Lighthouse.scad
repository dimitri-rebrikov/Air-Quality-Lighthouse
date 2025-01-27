cth=2; // wall thickens carrier

// esp card dimensions
esph=38.5; // height
espw=31; // width
espt=1.5; // thickness

// sensor card dimensions
senh=13.7;
senw=16.3;
sent=1.5;

// led card dimensions
ledw=9.4;
ledh=6.2;
ledt=1.9;

// generic holder
holdg=0.8; // groove to hold the card
holdwt=0.8; // wall thickness
holdbt=cth; // base thickness
holdxa=1.2; // extra thick wall area around groove
holdclr=0.2; // clearance between card and holder
holddi=5; // card distance to holder base
function holdh(cardh,hclr=holdclr,hxa=holdxa) = cardh+(hclr+hxa)*2;
function holdw(cardw,hclr=holdclr,hwt=holdwt) = cardw+(hclr+hwt)*2;
function holdd(cardt,hbt=holdbt,hdi=holddi,hxa=holdxa) = hbt+hdi+cardt+hxa;

// circuits carrier dimensions
cledholdd=holdd(ledt,hdi=1)-(ledt+2*holdxa); // how deep the led holder is integrated into carrier
cledh=cledholdd+5; // carrier height reserved for led
cesph=holdh(esph); // carrier height reserved for esp
cvwh=30; // carrier height reserver for the usb plug
cespw=sqrt(holdd(espt)^2+(holdw(espw)/2)^2)*2; // carrier width reserved for esp
ch=cledh+cesph+cvwh; // carrier height
cw=cespw; // carrier width
clh=ch-cledh; // carrier led area start height
cfth=cth*4; // carrier foot thickness

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
clr=0.2; // clearance between objects
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
hwifh=(floh-hwih)/3*2; // house windows height over floor
lrih=lwih/3*2; // light reflector height
lrita=tabr+lwih/2-lrih/2; // light reflector position

lr=th*2; // lock radius
loa=asin(cfth / (2*ri)) * 2 + 20; // lock outcut angle

odist=rbo*2+20; // object distance

module cardHolder(cardw,cardh,cardt,hwt=holdwt,hxa=holdxa,hbt=holdbt,hdi=holddi,hclr=holdclr,slide=false) {
    h=holdh(cardh,hclr,hxa);
    w=holdw(cardw,hclr,hwt);
    d=holdd(cardt,hbt,hdi,hxa);
    translate([-w/2,0,0])
    difference() {
        // base quader
        linear_extrude (d) 
            square([w, h]);
        // outcut for thick the groove area
        translate([hwt+hxa,0,hbt])
            linear_extrude(d)
                square([w-(hwt+hxa)*2, h]);
        // esp outcut
        if(!slide) {
            translate([hwt,(h-cardh)/2,hdi+hbt])
                linear_extrude(cardt) 
                    square([cardw,cardh]);
        } else {
            translate([hwt,(h-cardh)/2,hdi+hbt])
                linear_extrude(cardt) 
                    square([cardw,cardh+hxa+1]);
        }
        // outcut for the thin wall area
        translate([hwt,0,hbt])
            linear_extrude(hdi-hxa)
                square([w-hwt*2, h]);
    };  
}

module espHolder() {
    cardHolder(espw,esph,espt);
}

module senHolder() {
    cardHolder(senw,senh,sent);
}

module ledHolder() {
    cardHolder(ledw,ledh,ledt,hdi=1,hwt=2,slide=true);
}

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

module lock() {
    union() {
        rotate([0,0,90+loa/2])
            rotate_extrude(angle=180-loa, $fn=200)
                translate([ro, h0h+hwifh-lr*2, 0])  
                    lockOutline();
        rotate([0,0,-(90-loa/2)])
            rotate_extrude(angle=180-loa, $fn=200)
                translate([ro, h0h+hwifh-lr*2, 0])  
                    lockOutline();
    }
}

module bodyOutline() {
    polygon(points=[
        [ri,0],[ro,0],
        [ro,tab-ta*0.06],
        [rob,tab],[rob,tabr],[rib,tabr], 
        [rib,tab],[rol,tab],
        [rol,tar],[0,ta],
        [0,tar-th],[ril, tar-th],
        [ril,tab-th],[ri, clh]
    ]); 
}

module lightReflectorOutline() {
    polygon(points=[
        [0,tar],[0,lrita],[ril,tar]
    ]);
}   

// carrier is the vertical wall
// with circuit holders
module carrier() {
    difference() {
        translate([0,thr/2,0])
        rotate([90,0,0])
        union(){
            linear_extrude(cth)
                union() {
                    carrierOutline();
                    mirror([1,0,0])
                        carrierOutline();
                };
            carrierFoot();
            translate([0,cvwh,cth])
                rotate([0,180,0]) 
                    espHolder();
            translate([0,cvwh,0])
                senHolder();
            translate([0,ch-cledholdd,(holdh(ledh)+cth)/2])
                rotate([-90,0,0]) 
                    ledHolder();
        };
        translate([0,cfth/2+1,0]) 
            window(cfth+2,cw/2,cvwh);
        // clearance for the edges
        translate([clr,0,clr]) bodyComplete(); 
        translate([clr,0,-clr]) bodyComplete(); 
        translate([-clr,0,clr]) bodyComplete();  
        translate([-clr,0,-clr]) bodyComplete();  
    }
}

// because of the big hole in the carrier
// it has a thick foot for more sturdiness
module carrierFoot() {
    translate([-cw/2,0,cth/2])
    rotate([0,90,0])
    linear_extrude(cw)
    polygon(points=[
        [-cfth/2,0],[cfth/2,0],[cth/2,cvwh],[-cth/2,cvwh]
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

// base is the round puck
// on wich the carier is mounted
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

// base and carrier
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

// generich window
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
    for(ang = [-45,0,45]) {
        rotate([0,0,ang]) window(ro,hwiw,hwih);
    }
}

module h1windows() {
    for(ang = [-45,0,45]) {
        rotate([0,0,ang]) window(ro,hwiw,hwih);
    }
}

// body is the outer shell of the lighthouse
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
        lock();
    }
}

// ground floor for separate print
module groundFloorSeparate() {
    difference() {
        bodyComplete();
        translate([-rob,-rob,h1h]) cube([rob*2,rob*2,ta]);
    };
}

// first floor for separate print
module firstFloorSeparate() {
    color("red") translate([odist*2,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,h1h]);
        translate([-rob,-rob,h2h]) 
            cube([rob*2,rob*2,ta]);
    };
}

// second floor for separate print
module secondFloorSeparate() {
    translate([odist*3,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,h2h]);
        translate([-rob,-rob,tar]) cube([rob*2,rob*2,ta]);
    };
}

// roof for separate print
module roofSeparate() {
    color("red") translate([odist*4,0,0]) 
    difference() {
        bodyComplete();
        translate([-rob,-rob,0]) cube([rob*2,rob*2,tar]);
    };
}

// all parts together
module completeAssembly(){
    baseComplete();
    bodyComplete();
}

// x cross-section for check/docu
module projectionX() {
    projection(cut=true)
    rotate([-90,0,0])
    completeAssembly();
}

// y cross-section for check/docu
module projectionY() {
    projection(cut=true)
    rotate([0,-90,0])
    completeAssembly();
}

//ledHolder();
//rotate([90,0,0])
//    espHolder();
//    senHolder();
//lockOutline();
//lock();
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
translate([odist,0,0]) 
    groundFloorSeparate();
firstFloorSeparate();
secondFloorSeparate();
roofSeparate();
