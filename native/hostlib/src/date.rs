use std::time::SystemTime;

use chrono::{DateTime, Datelike, Timelike, Utc};

rustler::atoms! {
    iso_calendar_atom = "Elixir.Calendar.ISO",
}

#[derive(rustler::NifStruct)]
#[module = "NaiveDateTime"]
pub struct ElixirDateTime {
    calendar: rustler::Atom,
    day: u32,
    hour: u32,
    microsecond: (u32, u32),
    minute: u32,
    month: u32,
    second: u32,
    year: i32,
}

impl From<SystemTime> for ElixirDateTime {
    fn from(system_time: SystemTime) -> Self {
        let date_time: DateTime<Utc> = DateTime::from(system_time);

        Self {
            year: date_time.year(),
            month: date_time.month(),
            day: date_time.day(),
            hour: date_time.hour(),
            minute: date_time.minute(),
            second: date_time.second(),
            microsecond: (date_time.nanosecond() / 1000, 6),
            calendar: iso_calendar_atom(),
        }
    }
}
