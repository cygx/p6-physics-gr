unit package Physics;
use Physics::GR::LinAlg;
use Physics::GR::SymMath;
use Physics::GR::Symbolic;

class GR is export(:MANDATORY, :no-ops) {
    also does LinAlg;
    also does SymMath;
}

multi infix:<(x)>(Tensor $a, Tensor $b) is export { ... }

multi infix:<*>(Tensor $a, Tensor $b) is export { $a.MUL($b) // $b.RMUL($a) }
multi infix:<*>(Tensor $a, Numeric $b) is export { $a.MUL($b) }
multi infix:<*>(Tensor $a, Symbolic $b) is export { $a.MUL($b) }
multi infix:<*>(Numeric $a, Tensor $b) is export { $b.RMUL($a) }
multi infix:<*>(Symbolic $a, Tensor $b) is export { $b.RMUL($a) }

multi infix:<*>(Term $a, Numeric $b) is export { $a.MUL($b) }
multi infix:<*>(Term $a, Symbolic $b) is export { $a.MUL($b) }
multi infix:<*>(Symbolic $a, Term $b) is export { $b.MUL($a) }
multi infix:<*>(Numeric $a, Term $b) is export { $b.MUL($a) }
