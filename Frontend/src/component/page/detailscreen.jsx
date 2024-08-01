import React, { useState, useEffect } from 'react'
import {
    AppBar,
    Toolbar,
} from "@material-ui/core";
import { Link } from "react-router-dom";
import { Box, Typography } from '@mui/material';
import {
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Paper
} from '@material-ui/core';
import { HashLoader } from 'react-spinners';
import { apiGetRequest } from 'services/apiService';
import ArrowBackIosNewIcon from '@mui/icons-material/ArrowBackIosNew';
import { useParams } from 'react-router-dom';
export default function Detailscreen() {
    const [loading, setLoading] = useState(true);
    const [attendance, setAttendances] = useState([])
    let { id } = useParams();
    console.log(id);
    useEffect(() => {
        apiGetRequest(`teacher-courses/attendance/students/${id}`)
            .then(data => {
                setAttendances(data);
                 setLoading(false); // Set loading to false when data is fetched
            })
            .catch(error => {
                console.error('Error:', error);
                alert(error);
                setLoading(false); // Set loading to false in case of error
            });
    }, [id])
    return (
        <>
            <AppBar style={{ backgroundColor: "#1976d2" }}>
                {/* <CssBaseline /> */}
                <Toolbar style={{ display: "flex", flexDirection: "row", alignItems: "center" }}>
                    <ArrowBackIosNewIcon style={{ width: "20px" }} />
                    <Link to='/' style={{ color: "white", fontWeight: "bolder", fontSize: "20px", textDecorationLine: "none", marginLeft: "10px" }}>
                        HomeScreen
                    </Link>
                    {/* <Typography variant='p' style={{marginLeft:"500px"}}>
                        Attendance ID: {id}
                    </Typography> */}
                </Toolbar>
            </AppBar>
            
            <TableContainer component={Paper} style={{ marginTop: "100px", display: "flex", flexDirection: "row", justifyContent: "center", marginRight: "30px", width: "1080px", marginLeft: "100px" }}>
            {loading ? (
                    <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
                        <HashLoader color="#1976d2" />
                    </Box>
                ) : (
                <Table aria-label="simple table">
                    <TableHead>
                        <TableRow>
                            <TableCell>Roll No</TableCell>
                            <TableCell>Full Name</TableCell>
                            <TableCell>Status</TableCell>
                            <TableCell>Enrollment Status</TableCell>
                            <TableCell>Marked Time</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {attendance.length > 0 && attendance.map((studentList) => (
                            <TableRow key={studentList.id}>
                                <TableCell>{studentList.student.roll_no}</TableCell>
                                <TableCell>{studentList.student.full_name}</TableCell>
                                <TableCell>{studentList.status}</TableCell>
                                <TableCell>{studentList.enrollment_status ? "Enrolled" : "Not Enrolled"}</TableCell>
                                <TableCell>{new Date(studentList.created_at).toLocaleTimeString()}</TableCell>

                            </TableRow>
                        ))}
                        {attendance.length === 0 && (
                            <TableRow>
                                <TableCell colSpan={5}>No data available</TableCell>
                            </TableRow>
                        )}
                    </TableBody>

                </Table>
              )}

            </TableContainer>
        </>


    );
}
