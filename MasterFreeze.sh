#!/bin/bash

for ((i=1; i<=5; i+=1)) ; do
ext=`printf "%2.2i" $i`
next=`echo ''$i'+1' | bc`
NEXT=`printf "%1.1i" $next`

cd DIP.$i/1.freeze/
cp ../DISANG.all .
cp ../RST0.dip.$i .

  cat > amber-1.in <<EOF
NA and get alignment tensor
 &cntrl
    imin=1, irest=0, ntx=1,
    maxcyc=100, ncyc=100,
    ntpr=20,
    nsnb=50,
    cut=9.0,
    ntf=1, ntb=1,
    nmropt=1,
 /
 &wt type='END' /
LISTOUT=POUT
DISANG=./DISANG.all
DIPOLE=./RST0.dip.$i

END
EOF

  cat > qsub.sh <<EOF
#!/bin/bash
#PBS -l walltime=01:00:00,nodes=1:ppn=8
#PBS -N freeze.$ext

#Set location of Amber
export AMBERHOME=/ibbr/amber16
source \$AMBERHOME/amber.sh
export O_WORKDIR=`pwd`
SANDER=\$AMBERHOME/bin/sander.MPI

cd \$O_WORKDIR
PARM=../../tip4pew.10A.01.parm7
CRD=../../../1EQUIL/eq5.$ext.rst
# Run executable
TIME0=\`date +%s\`
\$SANDER -O -p \$PARM -i amber-1.in -c ../../../1EQUIL/eq5.01.rst -ref ../../../1EQUIL/eq5.01.rst -x min.1.nc -o min.1.out -inf min.1.info -r min.1.rst7
\$SANDER -O -p \$PARM -i amber-1.in -c ../../../1EQUIL/eq5.02.rst -ref ../../../1EQUIL/eq5.02.rst -x min.2.nc -o min.2.out -inf min.2.info -r min.2.rst7
\$SANDER -O -p \$PARM -i amber-1.in -c ../../../1EQUIL/eq5.03.rst -ref ../../../1EQUIL/eq5.03.rst -x min.3.nc -o min.3.out -inf min.3.info -r min.3.rst7
\$SANDER -O -p \$PARM -i amber-1.in -c ../../../1EQUIL/eq5.04.rst -ref ../../../1EQUIL/eq5.04.rst -x min.4.nc -o min.4.out -inf min.4.info -r min.4.rst7
\$SANDER -O -p \$PARM -i amber-1.in -c ../../../1EQUIL/eq5.05.rst -ref ../../../1EQUIL/eq5.05.rst -x min.5.nc -o min.5.out -inf min.5.info -r min.5.rst7
TIME1=\`date +%s\`
((TOTAL = \$TIME1 - \$TIME0))
echo "\$TOTAL seconds."

cd ../../DIP.$NEXT/1.freeze && qsub qsub.sh

exit 0
EOF
  
  chmod +x qsub.sh

cd ../../

done

