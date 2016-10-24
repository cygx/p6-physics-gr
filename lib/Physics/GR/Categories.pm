unit package Physics::GR;

role Symbolic is export {
    proto method MUL($) {*}
    multi method MUL($a: $b) is hidden-from-backtrace {
        fail "Don't know how to multiply {$a.^name} and {$b.^name}";
    }
    method RMUL($b: $a) is hidden-from-backtrace {
        $b.MUL($a) // fail "Don't know how to multiply {$a.^name} and {$b.^name}";
    }
}

role Algebraic is export {
    proto method MUL($) {*}
    proto method RMUL($) {*}
    multi method MUL($a: $b) is hidden-from-backtrace {
        fail "Don't know how to multiply {$a.^name} and {$b.^name}";
    }
    multi method RMUL($b: $a) is hidden-from-backtrace {
        fail "Don't know how to multiply {$a.^name} and {$b.^name}";
    }
}
