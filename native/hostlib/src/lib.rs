mod date;
mod file;

use file::FileStruct;
use std::fs;

#[rustler::nif]
fn list_files(path: String) -> Result<Vec<FileStruct>, String> {
    let path = if path == "" { ".".to_string() } else { path };

    let paths = match fs::read_dir(path) {
        Ok(paths) => paths,
        Err(_e) => return Err("Unable to read path".to_string()),
    };

    paths
        .map(|entry| {
            entry
                .map_err(|e| format!("Error reading entry: {:?}", e))
                .and_then(|e| FileStruct::from_entry(e).map_err(|e| e.to_string()))
        })
        .collect()
}

rustler::init!("Elixir.Host.HostLib", [list_files]);
