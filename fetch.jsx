import { run } from "uebersicht";

const opwmApiKey = "";

/**
 * OpenWeatherMaps accepts three parameters here:
 * 
 * kelvin
 * imperial
 * metric
 * 
 * Default is: kelvin
 */
const units = "";

const opacity = "cc";
const color = "#ffffff" + opacity;
const tintColor = "#e08201" + opacity;

export const className = `
    bottom: 0;
    left: 0;
    box-sizing: border-box;
    margin: auto;
    padding: 20px 20px 20px;
    color: ${color};
    font-family: Andale Mono;
    font-size: 0.8em;

    b {
        color: ${tintColor};
    }
`;

export const render = ({
    hostname,
    os,
    model,
    kernel,
    cpu,
    gpu,
    uptime,
    packages,
    memory,
    battery,
    date,
    localIp,
    mac,
    ssid,
    routerIp,
    weather,
}) => {
    const SystemSection = () => (
        <div id="system">
            {" "}
            <div>
                <b>┌ {hostname}</b>
            </div>
            <div>
                <b>│ OS: </b>
                {os}
            </div>
            <div>
                <b>│ Model: </b>
                {model}
            </div>
            <div>
                <b>│ Kernel: </b>
                {kernel}
            </div>
            <div>
                <b>│ Uptime: </b>
                {uptime}
            </div>
            <div>
                <b>│ Packages: </b>
                {packages}
            </div>
        </div>
    );

    const HardwareSection = () => (
        <div id="hardware">
            {" "}
            <div>
                <b>
                    │<br />├ CPU:{" "}
                </b>
                {cpu}
            </div>
            <div>
                <b>│ GPU: </b>
                {gpu}
            </div>
            <div>
                <b>│ Memory: </b>
                {memory}
            </div>
            <div>
                <b>│ Battery: </b>
                {battery}
            </div>
        </div>
    );

    const WeatherSection = () => (
        <div id="weather">
            <div>
                <b>
                    │<br />├ Date:{" "}
                </b>
                {date}
            </div>
            <div>
                <b>│ Location: </b>
                {weather.city}
            </div>
            <div>
                <b>│ Weather Summary: </b>
                {weather.conditions}
            </div>
            <div>
                <b>│ Temperature: </b>
                {weather.temp} °{units=="imperial" ? "F" : units=="kelvin" ? "K" : units=="metric" ? "C" : "K"}
            </div>
        </div>
    );

    const NetworkSection = () => (
        <div id="network">
            {" "}
            <div>
                <b>
                    │<br />├ Local IP:{" "}
                </b>
                {localIp}
            </div>
            <div>
                <b>│ Router IP: </b>
                {routerIp}
            </div>
            <div>
                <b>│ Mac Address: </b>
                {mac}
            </div>
            <div>
                <b>│ SSID: </b>
                {ssid}
            </div>
        </div>
    );

    return (
        <div>
            <SystemSection />
            <HardwareSection />
            <NetworkSection />
            <WeatherSection />
        </div>
    );
};

export const updateState = (data, previousState) => ({
    ...previousState,
    ...data,
});

const execute = (action, interval) => {
    action();

    setInterval(action, interval);
};

export const command = async (dispatch) => {
    // Most of the scripts are from https://github.com/dylanaraps/neofetch/blob/master/neofetch
    run(`./fetch/scripts/runOnce.sh`).then((data) => {
        const splitted = data.split("\n");
        dispatch({
            hostname: splitted[0],
            os: splitted[1],
            model: splitted[2],
            kernel: splitted[3],
            cpu: splitted[4],
            gpu: splitted[5],
            mac: splitted[6],
        });
    });

    execute(() => {
        run("./fetch/scripts/runEveryMinute.sh").then((data) => {
            const splitted = data.split("\n");
            dispatch({
                uptime: splitted[0],
                memory: splitted[1],
                battery: splitted[2],
                date: splitted[3],
                localIp: splitted[4],
                routerIp: splitted[5],
                ssid: splitted[6],
            });
        });
    }, 1000 * 60);

    // Update weather once in an hour
    execute(() => fetchWeather(dispatch), 1000 * 60 * 60);
};

const fetchWeather = (dispatch) => {
    geolocation.getCurrentPosition((geo) => {
        const lat = geo.position.coords.latitude;
        const lon = geo.position.coords.longitude;

        fetch(
            `http://127.0.0.1:41417/https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&units=${units}&appid=${opwmApiKey}&lang=en`
        )
            .then((res) => res.json())
            .then((data) => {
                let captalizeWord = text => text.toLowerCase().split(' ').map( (i, j) => i.charAt(0).toUpperCase()+i.slice(1)).join(' ')

                return dispatch({
                    weather: {
                        conditions: captalizeWord(data.weather[0].description),
                        temp: data.main.temp,
                        city: data.name,
                    },
                });
            });
    });
};

export const refreshFrequency = false;
