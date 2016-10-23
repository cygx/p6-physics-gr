use lib 'lib';
use Physics::GR;

say 5 * GR.matrix(<1 0 0>, <0 2 0>, <0 0 3>) * GR.vector(1, 2, 3);
