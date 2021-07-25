var x=setup();

macro "FDK Action Tool - C0f0H000ff800C000G000ff800" {
setBatchMode(1);
output ='Label,Count,Reds,Unsats,Defects,FDK\n';
tableName="Irigam";
if (!isOpen(tableName)) Table.create(tableName);
tableSize=Table.size;
id0 =  getImageID();
roiManager('reset');
t=getTitle();
run('Duplicate...', 'title=temp');
run('HSB Stack');
id =  getImageID();
setSlice(3);
run('Gaussian Blur...', 'sigma=10 slice');
run('Find Maxima...', 'noise=5 output=[Point Selection] slice');
getSelectionCoordinates(x, y);
output= output+t+",";
Table.set("Label",tableSize,t);
output= output+x.length+",";
Table.set("Count",tableSize,x.length);
Table.update;
setThreshold(0,70);
run('Convert to Mask', 'only');
run('Duplicate...', 'title=bmask slice');
run('Watershed', 'slice');
idmask = getImageID();
run('Analyze Particles...', 'add');
selectImage(id);
setSlice(1);
run ('Duplicate...', 'title=hue');
changeValues(1,16,255);
changeValues(235,255,255);
changeValues(17,234,0);
run('Convert to Mask', 'only');
run('Minimum...', 'radius=0.8 slice');
reds=0;
for (j=1; j<roiManager('count'); j++) {
        roiManager('select',j);
        roiManager ('Remove Slice Info');
        List.setMeasurements;
        tot = List.getValue('RawIntDen');
        if (tot>255*95) {
                run('Properties... ', 'position=none stroke=red');
                reds++;
        }
}

run('Select None');
selectImage(idmask);
run('Select None');
run('Create Selection');
run('Make Inverse');
selectImage(id0);
run('Restore Selection');
setBackgroundColor(0, 0, 0);
run('Clear', 'slice');
run('Select None');
run('Duplicate...', 'title=temp2');
run('HSB Stack');
setSlice(1);
run('Delete Slice');
run('Mean...', 'radius=25 stack');
run('Stack to Images');
imageCalculator('Difference create 32-bit', 'Brightness','Saturation');
unsat=0;
for (j=1; j<roiManager('count'); j++) {
        roiManager('select',j);
        List.setMeasurements;
        m = List.getValue('Mean');
        if (m>(58)) {
                run('Properties... ', 'position=none stroke=blue');
                unsat++;
        }
}
Table.set('Reds',tableSize,reds);
output= output+unsat+",";
Table.set('Unsat',tableSize,unsat);
output= output+(unsat+reds)+",";
Table.set('Defects',tableSize,unsat+reds);
output= output+d2s(100*(unsat+reds)/x.length,3)+"\n";
Table.set('FDK',tableSize,d2s(100*(unsat+reds)/x.length,3));

}

function setup() {
print ("-------------------------------------");
print ("Drag and drop images on the canvas.");
print ("Press the 'play' tool icon to compute FDK.");
print ("-------------------------------------");
return 1;
}
