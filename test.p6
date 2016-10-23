use lib 'lib';
use Physics::GR;

#say GR.unit-matrix(3);
#say GR.tensor(:sig<cc>, :2dim).set((0, 1, 42));
say ~GR.term(:x(4), :y(-1));
