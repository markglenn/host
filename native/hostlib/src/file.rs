use anyhow::Result;

mod file_types {
    rustler::atoms! {
        file,
        directory
    }
}

#[derive(rustler::NifStruct)]
#[module = "Host.Files.File"]
pub struct FileStruct {
    name: String,
    size: u64,
    file_type: rustler::Atom,
}

impl FileStruct {
    pub fn from_entry(dir_entry: std::fs::DirEntry) -> Result<Self> {
        let metadata = dir_entry.metadata()?;
        let name = match dir_entry.file_name().to_str() {
            Some(name) => name.to_string(),
            None => return Err(anyhow::anyhow!("Unable to convert file name to string")),
        };

        let file_type = if metadata.is_dir() {
            file_types::directory()
        } else {
            file_types::file()
        };

        Ok(Self {
            name,
            size: metadata.len(),
            file_type,
        })
    }
}
