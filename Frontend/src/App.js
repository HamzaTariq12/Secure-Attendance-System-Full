import React from 'react'
import { Route,Routes } from 'react-router-dom'
import Login from 'component/login'
import MainLayout from 'component/mainlayout'
import Detailscreen from 'component/page/detailscreen'
export default function App() {
  return (
   <>
   <Routes>
    <Route path='/' element={<Login/>} />
    <Route path='attendance' element={<MainLayout/>}/>
    <Route path='detailscreen/:id' element={<Detailscreen/>} />
   </Routes>
   </>
  )
}
