unit package Physics;
use Physics::GR::LinAlg;
use Physics::GR::SymMath;
use Physics::GR::Categories;

class GR is export(:MANDATORY, :no-ops) {
    also does LinAlg;
    also does SymMath;
}

multi infix:<(x)>(Tensor $a, Tensor $b) is export { ... }

multi prefix:<->(Symbolic $a) is export { $a.NEG }

multi infix:<*>(Algebraic $a, Algebraic $b) is export { $a.MUL($b) // $b.RMUL($a) }
multi infix:<*>(Algebraic $a, Numeric $b) is export { $a.MUL($b) }
multi infix:<*>(Algebraic $a, Symbolic $b) is export { $a.MUL($b) }
multi infix:<*>(Numeric $a, Algebraic $b) is export { $b.RMUL($a) }
multi infix:<*>(Symbolic $a, Algebraic $b) is export { $b.RMUL($a) }

multi infix:<*>(Symbolic $a, Symbolic $b) is export { $a.MUL($b) // $b.RMUL($a) }
multi infix:<*>(Symbolic $a, Numeric $b) is export { $a.MUL($b) }
multi infix:<*>(Numeric $a, Symbolic $b) is export { $b.RMUL($a) }
