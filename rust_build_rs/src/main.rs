use std::ffi::CString;

extern "C" {
    fn greet(name: *const std::os::raw::c_char);
}

fn main() {
    unsafe {
        let c = "world".to_string();
        let c = CString::new(c).unwrap();
        greet(c.as_ptr());
    }
}
