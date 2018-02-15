#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pp'

def loadDoc(uri)
    retryCount=5
    begin
        file=open(uri)
        text=file.read
        #把encoding设置为真正的encoding
        text.force_encoding("gbk")
        #把文件中的encoding改成正确的
        text.gsub!("gb2312","gbk")
        doc=Nokogiri::HTML(text)
        return doc
    rescue Exception => e  
        retryCount=retryCount-1
        if retryCount==0
            puts e.message
            return nil
        end
        retry
    end
end


uri="http://yyk.99.com.cn/city.html"
doc=loadDoc(uri)
content=doc.css("div#areacontent")
h4s=content.css("h4")
uls=content.css("ul")
data={}
length=h4s.length
counter=10000
start_counter=10000
for i in 0..length-1
    #puts h4s[i].text+' '+uls[i].css("li a")[0].text
    as=uls[i].css("li a")
    size=as.size
    prv=h4s[i].text
    
    for j in 0..size-1
        prv=as[j].text if(i==0)
        city=as[j].text


        #puts prv+"-"+as[j].text+"-"+as[j].attribute("href")
        uri2="http://yyk.99.com.cn"+as[j].attribute("href")
        doc2=loadDoc(uri2)
        next unless doc2

        fl=doc2.css("div.fontlist")
        as5=fl.css("li a")
        len2=as5.length
        
        #区
        for k in 0..len2-1
            counter=counter+1
            next if counter<start_counter
            doc4=loadDoc(as5[k].attribute("href"))
            district=as5[k].text.lstrip.rstrip
            as2=doc4.css("div.area_list").css("li a")
            siz2=as2.size
            dh4=doc4.css("div.tablist h4")[0]
            next unless dh4
            dist2=dh4.text.lstrip.rstrip.gsub("更多>>","")
            
            file=File.open(counter.to_s+"-"+prv+"-"+city+"-"+dist2+"-"+siz2.to_s+".csv","w+")
            bom = "\xEF\xBB\xBF" #Byte Order Mark
            file.write bom
            file.puts "省,市,区,全名,别名,性质,等级"
            puts "\n"+counter.to_s+"-"+"\t"+prv+"-"+city+"-"+dist2+":"+siz2.to_s
=begin
            for ii in 0..siz2-1
                puts "\t\t"+as2[ii].text+"\t"+as2[ii].attribute("href")
            end
            next
=end            
            for ii in 0..siz2-1
                uri3=as2[ii].attribute("href")
                #puts as2[ii].text+","+uri3
                doc3=loadDoc(uri3)
                next unless doc3
                realName=doc3.css("h1").text.lstrip
                lis3=doc3.css("div.hpi_content li")
                unless lis3[0]
                    file.puts prv+","+city+","+district+","+realName+",,,"
                    putc 'x'
                else
                    altName=lis3[0].text.gsub("医院别名：","")
                    character=lis3[1].text.gsub("医院性质：","").rstrip
                    level=lis3[2].text.gsub("医院等级：","")
                    file.puts prv+","+city+","+district+","+realName+","+altName+","+character+","+level
                    putc "."
                end
                file.flush
                
            end
            file.close 
        end
    end
end