package Physics::GR {
    role Symbolic {
        proto method MUL($) {*}
        multi method MUL($a: $b) is hidden-from-backtrace {
            fail "Don't know how to multiply {$a.^name} and {$b.^name}";
        }
        method RMUL($b: $a) is hidden-from-backtrace {
            $b.MUL($a) // fail "Don't know how to multiply {$a.^name} and {$b.^name}";
        }
    }

    role Algebraic {
        proto method MUL($) {*}
        proto method RMUL($) {*}
        multi method MUL($a: $b) is hidden-from-backtrace {
            fail "Don't know how to multiply {$a.^name} and {$b.^name}";
        }
        multi method RMUL($b: $a) is hidden-from-backtrace {
            fail "Don't know how to multiply {$a.^name} and {$b.^name}";
        }
    }
}

sub EXPORT {
    BEGIN Map.new((
        Symbolic => Physics::GR::Symbolic,
        Algebraic => Physics::GR::Algebraic,
    ));
}
