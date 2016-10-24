use lib 'lib';
use Physics::GR;
use Physics::GR::Symbolic;
use Physics::GR::SymMath;
use nqp;

#say GR.tensor(:sig<cc>, :2dim).set((0, 1, 42));
say GR.unit-matrix(2) * GR.term(:x(4), :y(-1));
