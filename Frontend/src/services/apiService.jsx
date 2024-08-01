import axios from 'axios';
const ApiURL = process.env.REACT_APP_BASE_URL;

const getHeader = () => {
    const token = localStorage.getItem("login_token");
    if (token) {
        return {
            'Content-Type':'application/json',
            "Authorization" : `Bearer ${token}`
        }
    }
    return {
        'Content-Type':'application/json'
    }
}
const api = axios.create({
    baseURL:ApiURL,
    headers: getHeader()
})





const loginRequest = async(email,password)=> {
    try {
        const response = await api.post('auth/login/',{email,password});
        console.log(response)
        const token = response.data.data.token.access_token;
        localStorage.setItem("login_token",token);
        return response.data.data;
    } catch (error) {
        throw error.data
    }
}



const logout = () => {
   delete api.defaults.headers.common["Authorization"];
    localStorage.removeItem('login_token');
}



const apiPostRequest = async(url,isFormData=false,data=null) =>{

    try {
        
        if(isFormData){
            api.defaults.headers[ 'Content-Type'] = 'multipart/form-data';
        }
        const response = await api.post(url,data);
        return response.data;
    }catch (error) {
        console.error(error);
        throw error.response.data.error
    }
}

const apiPutRequest = async(url,isFormData=false,data=null) =>{

    try {
        if(isFormData){
            api.defaults.headers[ 'Content-Type'] = 'multipart/form-data';
        }
        const response = await api.put(url,data);
        return response.data;
    }catch (error) {
        console.error(error);
        throw error.response.data.error
    }
}

axios.interceptors.request.use(
    (config)=> {
        const token = localStorage.getItem('login_token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
            console.log( `Bearer ${token}`)
            
        }
        return config; 
    },(error)=> {
        console.error(error.message)
        return Promise.reject(error);
    }
);
// const apiGetRequest = async(url) =>{
//     try {
//         const response = await api.get(url);
//         return response.data;
//     }catch (error) {
//         throw error.response.data.error
//     }
// }
const apiGetRequest = async (url) => {
    try {
        const response = await api.get(url);
        return response.data;
    } catch (error) {
        if (error.response && error.response.data && error.response.data.error) {
            throw error.response.data.error;
        } else {
            throw error; 
        }
    }
};


export {api,apiGetRequest,apiPostRequest,loginRequest,logout,apiPutRequest};