import React, { useState, useEffect } from 'react';
import Button from '@mui/material/Button';
import CssBaseline from '@mui/material/CssBaseline';
import TextField from '@mui/material/TextField';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import IconButton from '@mui/material/IconButton';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import CircularProgress from '@mui/material/CircularProgress';
import KFUEIT from 'assets/logo.png';
import toastr from 'toastr';
import 'toastr/build/toastr.min.css';
import { useNavigate } from 'react-router-dom';

import { loginRequest } from 'services/apiService';

function SignIn() {
    const [showPassword, setShowPassword] = useState(false);
    const [inputValues, setInputValues] = useState({
        email: '',
        password: '',
    });
    const [emailPassword,setemailpassword]=useState("")
    // const [emailError,setmailError]=useState('');
    // const [passwordError,setpasswordError]=useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    useEffect(() => {
        const token = localStorage.getItem('login_token');
        if (token) {
            navigate('/attendance');
        }
    }, [navigate]);

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setInputValues({
            ...inputValues,
            [name]: value,
        });
    };

    const handleLoginClick = (e) => {
        e.preventDefault();
        setLoading(true);
        loginRequest(inputValues.email, inputValues.password)
            .then((loginResponse) => {
                if (loginResponse.token) {
                    toastr.success('Login Successful');
                    navigate('/attendance');
                }
            })
            .catch((error) => {
                toastr.error('Invalid Email or Password');
                console.error('Error:', error);
                setemailpassword("Invalid Email or Password")

            })
            .finally(() => {
                setLoading(false);
            });
    };
 
    

    const handleTogglePasswordVisibility = () => {
        setShowPassword(!showPassword);
    };

    return (
        <ThemeProvider theme={createTheme()}>
            <Container component="main" maxWidth="xs">
                <CssBaseline />
                <Box
                    sx={{
                        marginTop: 8,
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                    }}
                >
                    <figure>
                        <img src={KFUEIT} alt="KFUEIT" style={{ width: '120px' }} />
                    </figure>
                    <Typography component="h1" variant="h5">
                        Sign in
                    </Typography>
                    <Box component="form" onSubmit={handleLoginClick} sx={{ mt: 1 }}>
                        <TextField
                            value={inputValues.email}
                            onChange={handleInputChange}
                            margin="normal"
                            required
                            fullWidth
                            id="email"
                            label="Email Address"
                            name="email"
                            autoComplete="email"
                            autoFocus
                        />
                        <TextField
                            value={inputValues.password}
                            onChange={handleInputChange}
                            margin="normal"
                            required
                            fullWidth
                            name="password"
                            label="Password"
                            type={showPassword ? 'text' : 'password'}
                            id="password"
                            autoComplete="current-password"
                            InputProps={{
                                endAdornment: (
                                    <IconButton
                                        aria-label="toggle password visibility"
                                        onClick={handleTogglePasswordVisibility}
                                        edge="end"
                                    >
                                        {showPassword ? <VisibilityOff /> : <Visibility />}
                                    </IconButton>
                                ),
                            }}
                        />
                           {emailPassword && (
                            <Typography variant="body2" color="error" align="center" gutterBottom>
                                {emailPassword}
                            </Typography>
                        )}
                        <Button type="submit" fullWidth variant="contained" sx={{ mt: 3, mb: 2 }}>
                            {loading ? <CircularProgress size={24} color="inherit" /> : 'Sign In'}
                        </Button>
                    </Box>
                </Box>
            </Container>
        </ThemeProvider>
    );
}

export default SignIn;
