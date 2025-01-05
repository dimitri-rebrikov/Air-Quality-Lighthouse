module lhOutline(ta=100, di=30, th=1.6, anr=45) {
    ri=di/2;
    ro=ri+th;
    rob=ro*1.1;
    rib=rob-th;
    rol=ro*0.8;
    ril=rol-th;
    tab=ta*0.65;
    tabr=tab+ta*0.05;
    tar=ta-tan(anr)*rol;
    thr=th/sin(90-anr);
    polygon( 
    points=[
        [ri,0],[ro,0],[ro,tab-ta*0.06],[rob,tab],[rob,tabr],[rib,tabr], [rib,tab],[rol,tab],[rol,tar],[0,ta],
    [0,ta-thr],[ril, tar-thr+th/tan(90-anr)],[ril,tab-th],[ri, tab-(ri-ril)*2]
    ]
    );
}
 
module lhBody() {
    rotate_extrude($fn=200)
        lhOutline();
}

lhBody();
//lhOutline();